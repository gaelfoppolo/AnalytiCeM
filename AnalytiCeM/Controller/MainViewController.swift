//
//  MainViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 16/04/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import CoreBluetooth
import UIKit

import LocationManagerSwift
import RealmSwift
import Sparrow
import SwiftSpinner

class MainViewController: UIViewController, IXNMuseListener, IXNMuseConnectionListener, IXNLogListener, IXNMuseDataListener, SPRequestPermissionEventsDelegate {
    
    // MARK: - Properties
    
    var manager: IXNMuseManagerIos?
    weak var muse: IXNMuse?
    
    var bluetoothAvailable: Bool = false {
        didSet {
            
        }
    }
    
    var internetAvailable: Bool = false {
        didSet {
            
        }
    }
    
    var owmManager: OWMManager!
    
    let maxDataPoints: Int = 500
    var emptyEEGHistory: Array<EEGSnapshot> = Array<EEGSnapshot>()
    
    var eegHistory: [EEGSnapshot] = [EEGSnapshot]()
    
    let realm = try! Realm()
    
    var weatherController: WeatherViewController!
    
    // MARK: - IBOutlet
    
    @IBOutlet var logView: UITextView!
    @IBOutlet weak var waveView: WaveView!
    
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var gpsView: GPSView!
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // get the manager of Muse (singleton)
        manager = IXNMuseManagerIos.sharedManager()
        
        // set the view as delegate
        manager?.museListener = self
        
        // register as log listener
        IXNLogManager.instance()?.setLogListener(self)
        
        owmManager = OWMManager(apiKey: APIKey.openWeatherMap.getKey()!)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateStr: String = dateFormatter.string(from: Date()) + (".log")
        print("\(dateStr)")
        
        emptyEEGHistory = Array<EEGSnapshot>(repeating: EEGSnapshot.allZeros, count: maxDataPoints)
        eegHistory = emptyEEGHistory
        
        refreshViews()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        // subscribe
        registerBluetoothStatusChange(handler: handleBluetoothChange)
        registerInternetStatusChange(handler: handleInternetChange)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // unsubscribe
        unregisterBluetoothStatusChange()
        unregisterInternetStatusChange()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*if let lastMuse = loadSavedMuse() {
            print(lastMuse)
        }*/
        setupLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        
        // button Add on the right
        let logoutButtonItem = UIBarButtonItem(image: UIImage(named: "main-logout"),
                                               style: .plain,
                                               target: self,
                                               action: #selector(MainViewController.logoutAction(_:))
                                )
        self.navigationItem.rightBarButtonItem = logoutButtonItem
        
        // @todo: will be removed, controller is not a good idea, switch to UIView only
        // the weather view to display
        weatherController = WeatherViewController(nibName: "WeatherViewController", bundle: nil)
        weatherView.layout(child: weatherController.view)
        
    }
    
    // MARK: - Location
    
    private func setupLocation() {
        
        // check permission
        guard SPRequestPermission.isAllowPermission(.locationWithBackground) else {
            
            // requestion permission to use location
            SPRequestPermission.dialog.interactive.present(on: self,
                                                           with: [.locationWithBackground],
                                                           delegate: self
            )
            
            return
            
        }
        
    }
    
    // MARK: - IBAction & UIButton
    
    @IBAction func disconnect(_ sender: Any) {
        /*if let muse = muse {
            muse.disconnect()
        }*/
        // @todo: test, to remove/move
        
        self.gpsView.activityIndicator.startAnimating()
        LocationManagerSwift.shared.updateLocation(completionHandler: { (latitude, longitude, status, error) in
            
            guard status == .OK else {
                
                // then error
                var errorMessage: String?
                
                if !self.internetAvailable {
                    errorMessage = "Internet is not available"
                }
                
                if let error = error, errorMessage == nil {
                    errorMessage = error.localizedDescription
                }
                
                self.gpsView.display(error: errorMessage ?? "Unknown error")
                self.gpsView.activityIndicator.stopAnimating()
                return
                
            }
            
            // update map
            self.gpsView.changeZoomToCoordinate(latitude: latitude, longitude: longitude)
            
            // retrieve locality
            LocationManagerSwift.shared.reverseGeocodeLocation(type: .APPLE, completionHandler: { (country, state, city, reverseGecodeInfo, placemark, error) in
                
                // city, country and marker
                guard let city = city, let country = country, let placemark = placemark else {
                    
                    // then error
                    var errorMessage: String?
                    
                    if !self.internetAvailable {
                        errorMessage = "Internet is not available"
                    }
                    
                    if let error = error, errorMessage == nil {
                        errorMessage = error.localizedDescription
                    }
                    
                    self.gpsView.display(error: errorMessage ?? "Unknown error")
                    self.gpsView.activityIndicator.stopAnimating()
                    return
                    
                }
                
                self.gpsView.addMarker(placemark: placemark)
                self.gpsView.display(city: city, country: country)
                self.gpsView.activityIndicator.stopAnimating()
                
            })
            
            
        })
    }
    
    @IBAction func scan(_ sender: Any) {
        //if (btManager.isBluetoothEnabled()) {
        manager?.startListening()
        //tableView.reloadData()
        //}
    }
    
    @IBAction func stopScan(_ sender: Any) {
        manager?.stopListening()
        //tableView.reloadData()
    }
    
    func logoutAction(_ sender: UIButton) {
        
        // create confirmation alert
        let alertController = UIAlertController(
            title: "Confirmation",
            message: "Are your sure you want to logout?",
            preferredStyle: .alert
        )
        
        // yes handler -> remove
        let yesAction = UIAlertAction(
            title: "Yes",
            style: .destructive,
            handler: { action in
                
                SwiftSpinner.show("Logout..")
                
                // logout
                let realm = try! Realm()
                let currentUser = realm.objects(User.self).filter("isCurrent == true").first
                
                // remove current user
                try! realm.write {
                    currentUser?.isCurrent = false
                }
                
                // after a second hide spinner
                // and display the login controller
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    SwiftSpinner.hide({
                        self.displayLogin()
                    })
                })
                
            }
        )
        alertController.addAction(yesAction)
        
        // no handler -> dismiss view only
        let noAction = UIAlertAction(
            title: "No",
            style: .cancel,
            handler: nil
        )
        alertController.addAction(noAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: - SPRequestPermissionEventsDelegate
    
    func didHide() {}
    
    func didAllowPermission(permission: SPRequestPermissionType) {
        print("permission is allowed")
    }
    
    func didDeniedPermission(permission: SPRequestPermissionType) {
        print("permission is denied")
    }
    
    func didSelectedPermission(permission: SPRequestPermissionType) {}
    
    // MARK: - BluetoothStatus
    
    func handleBluetoothChange(notification : Notification) {
        let status = notification.object as! CBManagerState
        
        self.bluetoothAvailable = (status == .poweredOn)
    }
    
    // MARK: - InternetStatus
    
    func handleInternetChange(notification : Notification) {
        let status = notification.object as! Bool
        
        self.internetAvailable = status
    }
    
    // MARK: - Muse
    
    func museListChanged() {
        //tableView.reloadData()
    }
    
    func receive(_ packet: IXNMuseConnectionPacket, muse: IXNMuse?) {
        print(muse?.getName())
        print(muse?.getMacAddress())
        
        var state: String
        switch packet.currentConnectionState {
            case .disconnected:
                state = "disconnected"
            case .connected:
                state = "connected"
            case .connecting:
                state = "connecting"
            case .needsUpdate:
                state = "needs update"
            case .unknown:
                state = "unknown"
        }
        
        print(state)
    }
    
    func receive(_ packet: IXNMuseDataPacket?, muse: IXNMuse?) {
        
        guard let packet = packet else { return }
        
        log(String(format: "%5.2f %5.2f %5.2f %5.2f", CDouble((packet.values()[IXNEeg.EEG1.rawValue])), CDouble((packet.values()[IXNEeg.EEG2.rawValue])), CDouble((packet.values()[IXNEeg.EEG3.rawValue])), CDouble((packet.values()[IXNEeg.EEG4.rawValue]))))
        
        // add data if valid
        let snapshot = EEGSnapshot(data: packet)
        if let snapshot = snapshot {
            eegHistory.append(snapshot)
            // forget surplus points
            eegHistory.removeSubrange(0 ..< max(0, eegHistory.count - maxDataPoints))
            refreshViews()
        }
        
        
        //        if (packet.packetType() == .alphaRelative /*|| packet?.packetType() == .eeg*/) {
        
        //        if let type = type {
        
        //let eeg1 = (packet.values()[IXNEeg.EEG1.rawValue])
        //
        //            log(String(format: "%5.2f %5.2f %5.2f %5.2f", CDouble((packet.values()[IXNEeg.EEG1.rawValue])), CDouble((packet.values()[IXNEeg.EEG2.rawValue])), CDouble((packet.values()[IXNEeg.EEG3.rawValue])), CDouble((packet.values()[IXNEeg.EEG4.rawValue]))))
        //        }
        
    }
    
    func receive(_ packet: IXNMuseArtifactPacket, muse: IXNMuse?) {
        if packet.blink {
            log("blink detected")
        }
        
        if packet.jawClench {
            log("jaw clench detected")
        }
    }
    
    func receiveLog(_ l: IXNLogPacket) {
        log(String(format: "%@: %llu raw:%d %@", l.tag, l.timestamp, l.raw as CVarArg, l.message))
    }
    
    func connect() {
        muse?.register(self)
        muse?.register(self, type: .artifacts)
        //muse?.register(self, type: .alphaAbsolute)
        //muse?.register(self, type: .alphaRelative)
        //muse?.register(self, type: .alphaScore)
        //muse?.register(self, type: .battery)
        //muse?.register(self, type: .)
        //muse?.unregisterAllListeners()
        
        //muse?.register(self, type: .betaRelative)
        
        muse?.runAsynchronously()
    }
    
    // MARK: - Business
    
    func log(_ message: String) {
        print("\(message)")
        //logLines?.insert(message, at: 0)
        //DispatchQueue.main.async(execute: {() -> Void in
        //self.logView.text = self.logLines?.joined(separator: "\n")
        //            self.logView.text = (self.logLines as NSArray).componentsJoined(by: "\n")
        //})
    }
    
    func refreshViews() {
        
        // recover only the property we want for each snapshot of the history
        waveView.points = eegHistory.map({
            return $0.value
        })
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

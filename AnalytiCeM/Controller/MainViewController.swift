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

class MainViewController: UIViewController, IXNMuseListener, IXNMuseConnectionListener, IXNMuseDataListener, SPRequestPermissionEventsDelegate {
    
    private enum MuseButtonStatus: Int {
        case connecting, connected, disconnected
    }
    
    // MARK: - Properties
    
    var locationTimer: Timer?
    var weatherTimer: Timer?
    var owmManager: OWMManager!
    
    var bluetoothAvailable: Bool? {
        
        willSet(newBluetoothStatus) {
            
            // if we loose Bluetooth, disconnect Muse
            if (bluetoothAvailable == true && newBluetoothStatus == false) {
                disconnect()
            }
            
            // if we gain Bluetooth
            if (bluetoothAvailable == false && newBluetoothStatus == true) {
                if let leftButton = self.navigationItem.leftBarButtonItem {
                    leftButton.isEnabled = true
                }
            }
            
            
        }
        
        didSet {
    
            if let leftButton = self.navigationItem.leftBarButtonItem {
                leftButton.isEnabled = leftButton.isEnabled && bluetoothAvailable!
            }
            
        }
    }
    
    var internetAvailable: Bool = false {
        didSet {
            
        }
    }
    
    // Muse
    var museManager: IXNMuseManagerIos?
    weak var muse: IXNMuse?
    var currentMuse: Results<Muse>?
    var currentUser: Results<User>?
    
    let maxDataPoints: Int = 500
    var emptyEEGHistory: Array<EEGSnapshot> = Array<EEGSnapshot>()
    var eegHistory: [EEGSnapshot] = [EEGSnapshot]()
    
    let realm = try! Realm()
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var sessionAction: UIButton!

    @IBOutlet weak var waveView: WaveView!
    
    @IBOutlet weak var weatherView: WeatherView!
    @IBOutlet weak var gpsView: GPSView!
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupManagers()
        
        setupRealm()
        
        setupUI()
        
        emptyEEGHistory = Array<EEGSnapshot>(repeating: EEGSnapshot.allZeros, count: maxDataPoints)
        eegHistory = emptyEEGHistory
        refreshViews()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        // subscribe
        registerBluetoothStatusChange(handler: handleBluetoothChange)
        registerInternetStatusChange(handler: handleInternetChange)
        updateHey()
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
        
        // button logout on the right
        let logoutButtonItem = UIBarButtonItem(image: UIImage(named: "main-logout"),
                                               style: .plain,
                                               target: self,
                                               action: #selector(MainViewController.logoutAction(_:))
                                )
        self.navigationItem.rightBarButtonItem = logoutButtonItem
        
        // title
        self.navigationItem.title = "AnalytiCeM"
        
        // set button to disconnected
        changeMuseButton(to: .disconnected)
        
        // todo: custom subclass of UIButton
        self.sessionAction.layer.cornerRadius = 5
        self.sessionAction.layer.borderColor = Theme.current.mainColor.cgColor
        self.sessionAction.layer.borderWidth = 1
        self.sessionAction.setTitleColor(Theme.current.mainColor, for: .normal)
        
        self.sessionAction.setImage(UIImage(named: "session-start"), for: .normal)
        self.sessionAction.setTitle("Start a new session", for: .normal)
        
        self.sessionAction.titleLabel?.numberOfLines = 1
        self.sessionAction.titleLabel?.adjustsFontSizeToFitWidth = true
        self.sessionAction.titleLabel?.lineBreakMode = .byClipping
        
    }
    
    private func updateHey() {
        self.topLabel.text = "Hey \(self.currentUser?.first?.firstName ?? "")"
    }
    
    private func setupManagers() {
        
        // manager of OpenWeatherMap
        owmManager = OWMManager(apiKey: APIKey.openWeatherMap.getKey()!)
        
        // get the manager of Muse (singleton)
        museManager = IXNMuseManagerIos.sharedManager()
        
        // set the view as delegate
        museManager?.museListener = self
        
    }
    
    // MARK: - Location
    
    private func setupLocation() {
        
        // check permission
        guard SPRequestPermission.isAllowPermission(.locationWithBackground) else {
            
            // requestion permission to use location
            SPRequestPermission.dialog.interactive.present(
                on: self,
                with: [.locationWithBackground],
                delegate: self
            )
            return
        }
        
        // we can init
        initLocationRefresher()
        initWeatherRefresher()
        
    }
    
    @objc private func updateLocation() {
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
    
    private func initLocationRefresher() {
        
        // in case of
        locationTimer?.invalidate()
        
        // init timer, every minute, until it's stopped
        locationTimer = Timer.scheduledTimer(
            timeInterval: 60,
            target: self,
            selector: #selector(updateLocation),
            userInfo: nil,
            repeats: true
        )
        
        // launch it now
        locationTimer?.fire()
    }
    
    private func stopLocationRefresher() {
        locationTimer?.invalidate()
    }
    
    // MARK: Weather
    
    @objc private func updateWeather() {
        self.weatherView.activityIndicator.startAnimating()
        
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
                
                self.weatherView.display(error: errorMessage ?? "Unknown error")
                self.weatherView.activityIndicator.stopAnimating()
                return
                
            }
            
            // get the weather
            self.owmManager.currentWeatherByCoordinatesAsJson(
                latitude: latitude,
                longitude: longitude,
                data: { result in
                    
                    switch result {
                        case .Success(let json):
                            let weather = Weather(json: json)
                            self.weatherView.display(weather: weather)
                            break
                        case .Error(let errorMessage):
                            self.weatherView.display(error: errorMessage)
                            break
                    }
                    
                    self.weatherView.activityIndicator.stopAnimating()
            
                }
            )
            
        })
        
    }
    
    private func initWeatherRefresher() {
        
        // in case of
        weatherTimer?.invalidate()
        
        // init timer, every 30 minutes, until it's stopped
        weatherTimer = Timer.scheduledTimer(
            timeInterval: 60*30,
            target: self,
            selector: #selector(updateWeather),
            userInfo: nil,
            repeats: true
        )
        
        // launch it now
        weatherTimer?.fire()
    }
    
    private func stopWeatherRefresher() {
        weatherTimer?.invalidate()
    }
    
    // MARK: - Realm
    
    private func setupRealm() {
        
        // get the current Muse
        currentMuse = realm.objects(Muse.self).filter("isCurrent == true")
        
        // get the current User
        currentUser = realm.objects(User.self).filter("isCurrent == true")
        
    }
    
    // MARK: - Muse Status Button
    
    private func changeMuseButton(to status: MuseButtonStatus) {
        
        // the attributes of the button to be set
        var button: (image: String, action: Selector?, enabled: Bool)
        
        switch status {
            case .connecting:
                button.image = "muse-connecting"
                button.enabled = false
                button.action = nil
                break
            case .connected:
                button.image = "muse-connected"
                button.enabled = true
                button.action = #selector(muse?.disconnect)
                break
            case .disconnected:
                button.image = "muse-disconnected"
                button.enabled = true
                // only if bluetooth is available
                if let bluetoothAvailable = bluetoothAvailable {
                    button.enabled = button.enabled && bluetoothAvailable
                }
                button.action = #selector(startResearchMuses)
                break
        }
        
        // button Muse status on the left
        let museStatusButtonItem = UIBarButtonItem(image: UIImage(named: button.image),
                                                   style: .plain,
                                                   target: self,
                                                   action: button.action
        )
        self.navigationItem.leftBarButtonItem = museStatusButtonItem
        self.navigationItem.leftBarButtonItem?.isEnabled = button.enabled
        
    }
    
    // MARK: - Muse
    
    @objc private func startResearchMuses() {
        
        self.muse = nil
        
        // only if we have bluetooth
        if let bluetoothAvailable = bluetoothAvailable, bluetoothAvailable {
            
            // start
            museManager?.startListening()
            // update to connecting status
            changeMuseButton(to: .connecting)
            
            // already Muses found, try to check
            if museManager?.getMuses().count != 0 {
               museListChanged()
            }
            
            // start a timer to stop after 5 seconds, if nothing found
            // prevent infinity search if no Muse, then list does not changed
            
            Timer.scheduledTimer(
                withTimeInterval: 5,
                repeats: false,
                block: { timer in
                    
                    if (self.muse == nil) {
                        self.disconnect()
                    }
                    
                }
            )

        }
    }
    
    func connect(to muse: IXNMuse) {
        
        // disconnect first (in case of)
        if let lMuse = self.muse, lMuse != muse {
            disconnect()
        }
        
        // save
        self.muse = muse
        
        // connection listener
        muse.register(self)
        // eeg data packet listener
        muse.register(self, type: .eeg)
        
        //muse?.register(self, type: .betaRelative)
        
        // launch
        muse.runAsynchronously()
    }
    
    func disconnect() {
        // stop listening to Muses
        museManager?.stopListening()
        // remove all listeners
        muse?.unregisterAllListeners()
        // disconnect
        muse?.disconnect()
        // change status
        changeMuseButton(to: .disconnected)
        // set
        self.muse = nil
    }
    
    // MARK: - IBAction & UIButton
    
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
        // we can init
        initLocationRefresher()
        initWeatherRefresher()
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
    
    // MARK: - MuseListener
    
    func museListChanged() {
        
        // get the muses found
        let listMuses = museManager!.getMuses()
        
        // current Muse
        guard let currentMuse = currentMuse?.first else {
            
            // disconnect
            disconnect()
            return
        }
        
        // name of the current Muse
        let lMuseName = currentMuse.getName()
        // check if Muse is in the list
        let museFound = listMuses.filter({ $0.getName() == lMuseName }).first
        
        // yep found
        if let museFound = museFound {
            
            // connect to it
            connect(to: museFound)
            
        // not found :(
        } else {
            
            // disconnect
            disconnect()
            
        }
        
    }
    
    func receive(_ packet: IXNMuseConnectionPacket, muse: IXNMuse?) {
        
        switch packet.currentConnectionState {
            case .disconnected:
                // case of, clean
                disconnect()
            case .connected:
                changeMuseButton(to: .connected)
            case .connecting:
                changeMuseButton(to: .connecting)
            default:
                break
        }
    }
    
    func receive(_ packet: IXNMuseDataPacket?, muse: IXNMuse?) {
        
        guard let packet = packet else { return }
        
        //log(String(format: "%5.2f %5.2f %5.2f %5.2f", CDouble((packet.values()[IXNEeg.EEG1.rawValue])), CDouble((packet.values()[IXNEeg.EEG2.rawValue])), CDouble((packet.values()[IXNEeg.EEG3.rawValue])), CDouble((packet.values()[IXNEeg.EEG4.rawValue]))))
        
        // todo: other thread
        
        // add data if valid
        /*let snapshot = EEGSnapshot(data: packet)
        if let snapshot = snapshot {
            eegHistory.append(snapshot)
            // forget surplus points
            eegHistory.removeSubrange(0 ..< max(0, eegHistory.count - maxDataPoints))
            refreshViews()
        }*/
        
        
        //        if (packet.packetType() == .alphaRelative /*|| packet?.packetType() == .eeg*/) {
        
        //        if let type = type {
        
        //let eeg1 = (packet.values()[IXNEeg.EEG1.rawValue])
        //
        //            log(String(format: "%5.2f %5.2f %5.2f %5.2f", CDouble((packet.values()[IXNEeg.EEG1.rawValue])), CDouble((packet.values()[IXNEeg.EEG2.rawValue])), CDouble((packet.values()[IXNEeg.EEG3.rawValue])), CDouble((packet.values()[IXNEeg.EEG4.rawValue]))))
        //        }
        
    }
    
    func receive(_ packet: IXNMuseArtifactPacket, muse: IXNMuse?) {
        if packet.blink {
            //log("blink detected")
        }
        
        if packet.jawClench {
            //log("jaw clench detected")
        }
    }
    
    // MARK: - WaveView
    
    func refreshViews() {
        
        // recover only the property we want for each snapshot of the history
        waveView.points = eegHistory.map({
            return $0.value
        })
        
    }

}

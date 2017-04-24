//
//  DeviceViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 18/04/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import RealmSwift
import UIKit

class DeviceViewController: UIViewController, IXNMuseListener, IXNMuseConnectionListener, IXNMuseDataListener, IXNMuseErrorListener, ChooseMuseDelegate {
    
    // MARK: - Properties
    
    var manager: IXNMuseManagerIos?
    weak var muse: IXNMuse?
    
    var btManager: BluetoothManager?
    
    let realm = try! Realm()
    var currentMuse: Results<Muse>?
    
    var currentStatus: String = "Unknown" {
        didSet {
            self.statusLabel.text = currentStatus
        }
    }
    // MARK: - IBOutlet
    
    @IBOutlet weak var viewDeviceIsSetup: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var refreshStatus: UIButton!
    
    @IBOutlet weak var setupLabel: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // retrieve current muse
        currentMuse = realm.objects(Muse.self)
        
        // create if not already did
        if currentMuse?.count == 0 {
            try! realm.write {
                realm.add(Muse())
            }
        }
        
        // get the manager of Muse (singleton)
        manager = IXNMuseManagerIos.sharedManager()
        
        // set the view as delegate
        manager?.museListener = self
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.imageView.image = UIImage(named: "settings-link-device")
        
        // name of the last Muse configured
        if let lMuse = currentMuse?.first, let _ = lMuse.getName() {
            
            self.refreshBtn(self.refreshStatus)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // manager of Bluetooth devices
        btManager = BluetoothManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // remove all registers on Muse
        disconnect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        self.navigationItem.title = "Device"
        self.deviceName.adjustsFontSizeToFitWidth = true
        self.setupLabel.adjustsFontSizeToFitWidth = true
        self.batteryLabel.isHidden = true
        
        self.statusLabel.text = currentStatus
        self.refreshStatus.setTitle("Refresh", for: .normal)
        
        // hide both view by default
        self.viewDeviceIsSetup.isHidden = true
        self.setupLabel.isHidden = true
        
        setupElements()
    }
    
    private func setupElements() {
        // name of the last Muse configured
        if let lMuse = currentMuse?.first, let museName = lMuse.getName() {
            
            // display view
            self.viewDeviceIsSetup.isHidden = false
            self.setupLabel.isHidden = true
            
            self.deviceName.text = museName
            
            // display battery if information
            if let battery = lMuse.getBattery() {
                updateBattery(batteryLevel: battery)
            }
            
            self.button.setTitle("Remove", for: .normal)
            self.button.setTitleColor(UIColor.red, for: .normal)
            
        } else {
            
            // display view
            self.setupLabel.isHidden = false
            self.viewDeviceIsSetup.isHidden = true
            
            self.setupLabel.text = "Setup a new device"
            self.button.setTitle("Add a new Muse", for: UIControlState.normal)
            self.button.setTitleColor(UIColor.blue, for: .normal)
        }
    }
    
    private func updateBattery(batteryLevel: Double) {
        self.batteryLabel.text = String("\(batteryLevel)%")
        self.batteryLabel.isHidden = false
    }
    
    // MARK: - IBAction
    
    @IBAction func actionBtn(_ sender: UIButton) {
        
        // muse -> delete
        if let lMuse = currentMuse?.first, let museName = lMuse.getName() {
            
            // create confirmation alert
            let alertController = UIAlertController(
                title: "Confirmation",
                message: "Are your sure you want to delete \(museName)?",
                preferredStyle: .alert
            )
            
            // yes handler -> remove
            let yesAction = UIAlertAction(
                title: "Yes",
                style: .destructive,
                handler: { action in
                    
                    // remove listener
                    self.disconnect()
            
                    // remove it from DB
                    let realm = try! Realm()
                    try! realm.write {
                        realm.delete(lMuse)
                        realm.add(Muse())
                    }
                
                    // update view
                    self.setupElements()
            
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
        
        // no muse -> add view
        } else {
            
            // the view to display
            let lPopupVC = AddMuseViewController(nibName: "AddMuseViewController", bundle: nil)
            
            // no background
            lPopupVC.view.backgroundColor = UIColor.clear
            
            // on top of the parent view
            lPopupVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            
            lPopupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            
            // register as delegate
            lPopupVC.delegate = self
            
            // display
            self.present(lPopupVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func refreshBtn(_ sender: UIButton) {
        
        // disable button
        self.refreshStatus.isEnabled = false
        // launch search
        self.manager?.startListening()
        self.activity.startAnimating()
        
        // create a delay of five seconds
        let delay = DispatchTime.now() + 5
        
        // stop search and enable button after that delay
        DispatchQueue.main.asyncAfter(deadline: delay) {
            self.manager?.stopListening()
            self.activity.stopAnimating()
            self.refreshStatus.isEnabled = true
        }
    }
    
    
    // MARK: - ChooseMuseDelegate
    
    func didChoose(muse: IXNMuse) {
        
        // to DB
        saveCurrent(muse: muse)
        
        // update UI
        setupElements()
        
        // disconnect first
        disconnect()
        
        // stop searching (if was auto-connect)
        manager?.stopListening()
        
        // try to connect to the Muse found
        self.muse = muse
        connect()
    }
    
    // MARK: - Realm
    
    func saveCurrent(muse: IXNMuse) {
        // current muse
        if let lMuse = currentMuse?.first {
            
            // get & set Muse's name
            let museName = muse.getName()
            
            // update it
            try! realm.write {
                lMuse.setValue(museName, forKeyPath: "name")
            }
        }
    }
    
    // MARK: - MuseListener
    
    func museListChanged() {
        // get the muses found
        let listMuses = manager!.getMuses()
        // name of the last Muse configured
        let lMuseName = currentMuse?.first?.getName()
        // check if last Muse is in the list
        let museFound = listMuses.filter({ $0.getName() == lMuseName }).first
        
        // yep found
        if let museFound = museFound {
            
            // then choose it
            didChoose(muse: museFound)
            
        // not found :(
        } else {
            
            self.currentStatus = "Not found"
            
        }
    }
    
    // MARK: - MuseConnectionListener
    
    func receive(_ packet: IXNMuseConnectionPacket, muse: IXNMuse?) {
        // todo: improve
        switch packet.currentConnectionState {
            case .disconnected:
                self.currentStatus = "Disconnected"
                break
            case .connected:
                self.currentStatus = "Connected"
                break
            case .connecting:
                self.currentStatus = "Connecting"
                break
            default:
                break
        }
    }
    
        // MARK: - MuseDataListener
    
    func receive(_ packet: IXNMuseDataPacket?, muse: IXNMuse?) {
        // only packet about battery
        if packet?.packetType() == .battery {
            
            // get the potential battery level
            let battery = packet?.getBatteryValue(IXNBattery(rawValue: IXNBattery.chargePercentageRemaining.rawValue)!)
            
            // check battery is valid
            guard let batteryValue = battery, !batteryValue.isNaN else { return }
            
            if let lMuse = currentMuse?.first {

                // update it
                try! realm.write {
                    lMuse.setValue(batteryValue, forKeyPath: "remaningBattery")
                }
                
                // update UI
                updateBattery(batteryLevel: batteryValue)
            }
        }
    }
    
    func receive(_ packet: IXNMuseArtifactPacket, muse: IXNMuse?) {}
    
    // MARK: - MuseErrorListener
    
    func receiveError(_ error: IXNError) {
        // todo: handle error
    }
    
    // MARK: - Business
    
    func connect() {
        muse?.register(self as IXNMuseConnectionListener)
        muse?.register(self, type: .battery)
        muse?.register(self as IXNMuseErrorListener)
        muse?.runAsynchronously()
    }
    
    func disconnect() {
        manager?.stopListening()
        muse?.unregisterAllListeners()
        muse?.disconnect()
    }

    // MARK: - Navigation

}

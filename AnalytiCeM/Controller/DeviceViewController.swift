//
//  DeviceViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 18/04/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import RealmSwift
import UIKit

class DeviceViewController: UIViewController, IXNMuseConnectionListener, IXNMuseListener, ChooseMuseDelegate {
    
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
        
        //UIApplication.shared.isIdleTimerDisabled = true
        
        // get the manager of Muse (singleton)
        //manager = IXNMuseManagerIos.sharedManager()
        
        // set the view as delegate
        //manager?.museListener = self
        
        // manager of Bluetooth devices
        //btManager = BluetoothManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.imageView.image = UIImage(named: "settings-link-device")
        
        // name of the last Muse configured
        if let lMuse = currentMuse?.first, let _ = lMuse.getName() {
            manager?.startListening()
        }
        
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
                self.batteryLabel.text = String("\(battery)%")
                self.batteryLabel.isHidden = false
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
    
    // MARK: - Muse
    
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
    
    func receive(_ packet: IXNMuseConnectionPacket, muse: IXNMuse?) {
        
        switch packet.currentConnectionState {
            case .disconnected:
                self.currentStatus = "Disconnected"
                break
            case .connected:
                // only get configuration when connected
                if let lMuse = currentMuse?.first {
                    
                    let battery: Double = self.muse!.getConfiguration()!.getBatteryPercentRemaining()
                
                    // update it
                    try! realm.write {
                        lMuse.setValue(battery, forKeyPath: "remaningBattery")
                    }
                    
                    setupElements()
                }
                self.currentStatus = "Connected"
                break
            case .connecting:
                self.currentStatus = "Connecting"
                break
            default:
                break
        }
    }
    
    // MARK: - Business
    
    func connect() {
        muse?.register(self)
        muse?.runAsynchronously()
    }
    
    func disconnect() {
        manager?.stopListening()
        muse?.unregisterAllListeners()
        muse?.disconnect()
    }

    // MARK: - Navigation

}

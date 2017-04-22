//
//  DeviceViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 18/04/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import RealmSwift
import UIKit

class DeviceViewController: UIViewController, IXNMuseConnectionListener, ChooseMuseDelegate {
    
    // MARK: - Properties
    
    //var manager: IXNMuseManagerIos?
    weak var muse: IXNMuse?
    
    var btManager: BluetoothManager?
    let realm = try! Realm()
    var currentMuse: Results<Muse>?
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var batteryLabel: UILabel!
    
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
        
        // todo:
        // try to connect if already one saved
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        self.navigationItem.title = "Device"
        self.deviceName.adjustsFontSizeToFitWidth = true
        self.batteryLabel.isHidden = true
        setupElements()
    }
    
    private func setupElements() {
        // name of the last Muse configured
        if let lMuse = currentMuse?.first, let museName = lMuse.getName() {
            
            self.deviceName.text = museName
            
            // display battery if information
            if let battery = lMuse.getBattery() {
                self.batteryLabel.text = String("\(battery)%")
                self.batteryLabel.isHidden = false
            }
            
            self.button.setTitle("Remove", for: .normal)
            self.button.setTitleColor(UIColor.red, for: .normal)
            
        } else {
            
            self.deviceName.text = "Setup a new device"
            self.batteryLabel.isHidden = true
            self.button.setTitle("Add a new Muse", for: UIControlState.normal)
            self.button.setTitleColor(UIColor.blue, for: .normal)
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func actionBtn(_ sender: UIButton) {
        
        // todo:
        // handle remove action
        
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
    
    // MARK: - ChooseMuseDelegate
    
    func didChoose(muse: IXNMuse) {
        print("Choosen: \(muse.getName())")
        // to DB
        saveCurrent(muse: muse)
        // update UI
        setupElements()
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
    
    func receive(_ packet: IXNMuseConnectionPacket, muse: IXNMuse?) {
        switch packet.currentConnectionState {
            case .disconnected:
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
            
            case .connecting:
                break
            case .needsUpdate:
                break
            case .unknown:
                break
        }
    }
    
    func connect() {
        muse?.register(self)
        muse?.runAsynchronously()
    }
    
    //cellForRowAt
    /*
     cell?.textLabel?.text = muse?.getName()
     if !(muse?.isLowEnergy())! {
     cell?.textLabel?.text = (cell?.textLabel?.text)! + (muse?.getMacAddress())!
     }
     }
     
     let lockQueue = DispatchQueue(label: "self.muse")
     lockQueue.sync {
     if self.muse == nil {
     self.muse = muse
     }
     else if self.muse != muse {
     self.muse?.disconnect()
     self.muse = muse
     }
     
     }
     connect()
     saveMuse(name: self.muse!.getName())
     print(self.muse?.getConfiguration())
     log(String(format: "======Choose to connect muse %@ %@======\n", (self.muse?.getName())!, (self.muse?.getMacAddress())!))
     }
     }*/
    
    
    // MARK: - Business
    
    func log(_ message: String) {
        print("\(message)")
        //logLines?.insert(message, at: 0)
        //DispatchQueue.main.async(execute: {() -> Void in
        //self.logView.text = self.logLines?.joined(separator: "\n")
        //            self.logView.text = (self.logLines as NSArray).componentsJoined(by: "\n")
        //})
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

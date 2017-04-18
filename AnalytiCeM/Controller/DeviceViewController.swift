//
//  DeviceViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 18/04/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import UIKit

class DeviceViewController: UIViewController, IXNMuseConnectionListener, ChooseMuseDelegate {
    
    // MARK: - Properties
    
    //var manager: IXNMuseManagerIos?
    weak var muse: IXNMuse?
    
    var btManager: BluetoothManager?
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var button: UIButton!
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Device"
        
        self.deviceName.adjustsFontSizeToFitWidth = true
        
        if let currentMuse = loadSavedMuse() {
            
            self.deviceName.text = currentMuse
            self.button.setTitle("Remove", for: UIControlState.normal)
            
        } else {
        
            self.deviceName.text = "Setup a new device"
            self.button.setTitle("Add a new Muse", for: UIControlState.normal)
        
        }
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction
    
    @IBAction func actionBtn(_ sender: UIButton) {
        
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
        self.muse = muse
        connect()
    }
    
    // MARK: - Muse
    
    func receive(_ packet: IXNMuseConnectionPacket, muse: IXNMuse?) {
        var state: String
        switch packet.currentConnectionState {
        case .disconnected:
            state = "disconnected"
        case .connected:
            state = "connected"
            // only get configuration when connected
            print("Battery \(self.muse?.getConfiguration()?.getBatteryPercentRemaining())")
        case .connecting:
            state = "connecting"
        case .needsUpdate:
            state = "needs update"
        case .unknown:
            state = "unknown"
        }
        log(String(format: "connect: %@", state))
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
    
    func saveMuse(name: String) {
        UserDefaults.standard.set(name, forKey: "lastMuse")
    }
    
    func loadSavedMuse() -> String? {
        
        return UserDefaults.standard.string(forKey: "lastMuse")
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

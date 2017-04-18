//
//  DeviceViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 18/04/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import UIKit

class DeviceViewController: UIViewController, IXNMuseConnectionListener, IXNMuseListener {
    
    // MARK: - Properties
    
    var manager: IXNMuseManagerIos?
    weak var muse: IXNMuse?
    
    var btManager: BluetoothManager!
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Device"
        
        //UIApplication.shared.isIdleTimerDisabled = true
        
        // get the manager of Muse (singleton)
        manager = IXNMuseManagerIos.sharedManager()
        
        // set the view as delegate
        manager?.museListener = self
        
        // manager of Bluetooth devices
        //btManager = BluetoothManager()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Muse
    
    func museListChanged() {
        //tableView.reloadData()
        print("Before \(manager!.getMuses().count)")
        manager?.stopListening()
        print("After \(manager!.getMuses().count)")
    }
    
    func receive(_ packet: IXNMuseConnectionPacket, muse: IXNMuse?) {
        var state: String
        switch packet.currentConnectionState {
        case .disconnected:
            state = "disconnected"
        case .connected:
            state = "connected"
            // only get configuration when connected
        // print(self.muse?.getConfiguration()?.getBatteryPercentRemaining())
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

    
    // number of Muse found
    //return manager!.getMuses().count
    
    //cellForRowAt
    /*let simpleTableIdentifier: String = "nil"
     
     var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: simpleTableIdentifier)
     if cell == nil {
     cell = UITableViewCell(style: .default, reuseIdentifier: simpleTableIdentifier)
     }
     let muses: [Any] = manager!.getMuses()
     if indexPath.row < muses.count {
     let muse: IXNMuse? = (manager?.getMuses()[indexPath.row])
     cell?.textLabel?.text = muse?.getName()
     if !(muse?.isLowEnergy())! {
     cell?.textLabel?.text = (cell?.textLabel?.text)! + (muse?.getMacAddress())!
     }
     }
     return cell!*/
    
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     var muses: [Any] = manager!.getMuses()
     if indexPath.row < muses.count {
     let muse: IXNMuse? = (muses[indexPath.row] as? IXNMuse)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  SimpleController.swift
//  MuseTest
//
//  Created by Gaël on 03/04/2017.
//  Copyright © 2017 Gaël. All rights reserved.
//

import UIKit
import CoreBluetooth

class SimpleController: UIViewController, IXNMuseConnectionListener, IXNMuseDataListener, IXNMuseListener, IXNLogListener, UITableViewDelegate, UITableViewDataSource {
    
    var manager: IXNMuseManagerIos?
    weak var muse: IXNMuse?
    var logLines = [Any]()
    var isLastBlink: Bool = false
    var btManager: CBCentralManager?
    var isBtState: Bool = false
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var logView: UITextView!

    override func viewDidLoad() {
            super.viewDidLoad()
            UIApplication.shared.isIdleTimerDisabled = true
            if manager == nil {
                manager = IXNMuseManagerIos.sharedManager()
            }
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        manager = IXNMuseManagerIos.sharedManager()
        manager?.museListener = self
        tableView = UITableView()
        logView = UITextView()
        logLines = [Any]()
        logView.text = ""
        IXNLogManager.instance()?.setLogListener(self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateStr: String = dateFormatter.string(from: Date()) + (".log")
        print("\(dateStr)")
        btManager = CBCentralManager(delegate: self as? CBCentralManagerDelegate, queue: nil, options: nil)
        isBtState = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func log(_ message: String) {
        print("\(message)")
        logLines.insert(message, at: 0)
        DispatchQueue.main.async(execute: {() -> Void in
            self.logView.text = (self.logLines as NSArray).componentsJoined(by: "\n")
        })
    }
    
    func receiveLog(_ l: IXNLogPacket) {
        log(String(format: "%@: %llu raw:%d %@", l.tag, l.timestamp, l.raw as CVarArg, l.message))
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isBtState = (btManager?.state == .poweredOn)
    }
    
    func isBluetoothEnabled() -> Bool {
        return isBtState
    }
    
    func museListChanged() {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager!.getMuses().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let simpleTableIdentifier: String = "nil"
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
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            log(String(format: "======Choose to connect muse %@ %@======\n", (self.muse?.getName())!, (self.muse?.getMacAddress())!))
        }
    }
    
    func receive(_ packet: IXNMuseConnectionPacket, muse: IXNMuse?) {
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
        log(String(format: "connect: %@", state))
    }
    
    func connect() {
        muse?.register(self)
        muse?.register(self, type: .artifacts)
        //muse?.register(self, type: .alphaAbsolute)
        /*
         [self.muse registerDataListener:self
         type:IXNMuseDataPacketTypeEeg];
         */
        muse?.register(self, type: .alphaRelative)
        muse?.register(self, type: .betaRelative)
        muse?.register(self, type: .deltaRelative)
        muse?.register(self, type: .gammaRelative)
        muse?.register(self, type: .thetaRelative)
        muse?.runAsynchronously()
    }
    
    func receive(_ packet: IXNMuseDataPacket?, muse: IXNMuse?) {
        
        var type: String?;
        switch packet!.packetType() {
        case .alphaRelative:
            type = "Alpha"
        case .betaRelative:
            type = "Beta"
        case .deltaRelative:
            type = "Delta"
        case .gammaRelative:
            type = "Gamma"
        case .thetaRelative:
            type = "Theta"
        default: break
        }
        
        //if (packet!.packetType() == .alphaRelative /*|| packet?.packetType() == .eeg*/) {
            
        if let type = type {
            
            log(String(format: "\(type) = %5.2f %5.2f %5.2f %5.2f", CDouble((packet?.values()[IXNEeg.EEG1.rawValue])!), CDouble((packet?.values()[IXNEeg.EEG2.rawValue])!), CDouble((packet?.values()[IXNEeg.EEG3.rawValue])!), CDouble((packet?.values()[IXNEeg.EEG4.rawValue])!)))
        }
        
    }
    
    func receive(_ packet: IXNMuseArtifactPacket, muse: IXNMuse?) {
        if packet.blink && packet.blink != isLastBlink {
            log("blink detected")
        }
        isLastBlink = packet.blink
        
        if packet.jawClench {
            log("jaw clench detected")
        }
    }
    
    func applicationWillResignActive() {
        print("disconnecting before going into background")
        muse?.disconnect()
    }
    
    @IBAction func disconnect(_ sender: Any) {
        if let muse = muse {
            muse.disconnect()
        }
    }
    
    @IBAction func scan(_ sender: Any) {
        manager?.startListening()
        tableView.reloadData()
    }
    
    @IBAction func stopScan(_ sender: Any) {
        manager?.stopListening()
        tableView.reloadData()
    }
    
}

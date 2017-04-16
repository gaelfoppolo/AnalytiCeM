//
//  SettingsViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 16/04/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import UIKit
import CoreBluetooth

class SettingsViewController: UIViewController, IXNMuseConnectionListener, IXNMuseDataListener, IXNMuseListener, IXNLogListener, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    var manager: IXNMuseManagerIos?
    weak var muse: IXNMuse?
    var logLines: [String]?
    var isLastBlink: Bool = false
    var btManager: CBCentralManager?
    var isBtState: Bool = false
    
    let maxDataPoints: Int = 500
    var emptyEEGHistory: Array<EEGSnapshot> = Array<EEGSnapshot>()
    
    var eegHistory: [EEGSnapshot] = [EEGSnapshot]()
    
    // MARK: - IBOutlet
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var logView: UITextView!
    @IBOutlet weak var waveView: WaveView!
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        // get the manager of Muse (singleton)
        if manager == nil {
            manager = IXNMuseManagerIos.sharedManager()
        }
        
        // set the view as delegate
        manager?.museListener = self
        
        // register as log listener
        IXNLogManager.instance()?.setLogListener(self)
        
        // manager of Bluetooth devices
        btManager = CBCentralManager(delegate: self as? CBCentralManagerDelegate, queue: nil, options: nil)
        
        // current state of Bluetooth
        isBtState = false
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //tableView = UITableView()
        //logView = UITextView()
        
        // properties instance
        // @todo
        logLines = [String]()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateStr: String = dateFormatter.string(from: Date()) + (".log")
        print("\(dateStr)")
        
        emptyEEGHistory = Array<EEGSnapshot>(repeating: EEGSnapshot.allZeros, count: maxDataPoints)
        eegHistory = emptyEEGHistory
        
        refreshViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction
    
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
    
    // MARK: - TableView
    
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
            saveMuse(name: self.muse!.getName())
            print(self.muse?.getConfiguration())
            log(String(format: "======Choose to connect muse %@ %@======\n", (self.muse?.getName())!, (self.muse?.getMacAddress())!))
        }
    }
    
    // MARK: - CBCentralManager
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isBtState = (btManager?.state == .poweredOn)
    }
    
    // MARK: - Muse
    
    func receiveLog(_ l: IXNLogPacket) {
        log(String(format: "%@: %llu raw:%d %@", l.tag, l.timestamp, l.raw as CVarArg, l.message))
    }
    
    func museListChanged() {
        tableView.reloadData()
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
        muse?.register(self, type: .artifacts)
        //muse?.register(self, type: .alphaAbsolute)
        //        muse?.register(self, type: .alphaRelative)
        //        muse?.register(self, type: .alphaScore)
        //muse?.unregisterAllListeners()
        
        muse?.register(self, type: .betaRelative)
        
        muse?.runAsynchronously()
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
        if packet.blink && packet.blink != isLastBlink {
            log("blink detected")
        }
        isLastBlink = packet.blink
        
        if packet.jawClench {
            log("jaw clench detected")
        }
    }
    
    // MARK: - Business
    
    func log(_ message: String) {
        print("\(message)")
        logLines?.insert(message, at: 0)
        DispatchQueue.main.async(execute: {() -> Void in
            self.logView.text = self.logLines?.joined(separator: "\n")
//            self.logView.text = (self.logLines as NSArray).componentsJoined(by: "\n")
        })
    }
    
    func isBluetoothEnabled() -> Bool {
        return isBtState
    }
    
    func refreshViews() {
        
        // recover only the property we want for each snapshot of the history
        waveView.points = eegHistory.map({
            return $0.value
        })
        
        //        func extractBand(_ extractValue: (EEGSnapshot) -> Double) -> [Double] {
        //            return eegHistory.map(extractValue)
        //        }
        //
        //        waveView.points = extractBand { $0.value }
        
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

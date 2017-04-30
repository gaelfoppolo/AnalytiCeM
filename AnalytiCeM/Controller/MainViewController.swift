//
//  MainViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 16/04/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, IXNMuseListener, IXNMuseConnectionListener, IXNLogListener, IXNMuseDataListener {
    
    // MARK: - Properties
    
    var manager: IXNMuseManagerIos?
    weak var muse: IXNMuse?
    
    var btManager: BluetoothStatusManager!
    
    let maxDataPoints: Int = 500
    var emptyEEGHistory: Array<EEGSnapshot> = Array<EEGSnapshot>()
    
    var eegHistory: [EEGSnapshot] = [EEGSnapshot]()
    
    // MARK: - IBOutlet
    
    @IBOutlet var logView: UITextView!
    @IBOutlet weak var waveView: WaveView!

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the manager of Muse (singleton)
        manager = IXNMuseManagerIos.sharedManager()
        
        // set the view as delegate
        manager?.museListener = self
        
        // register as log listener
        IXNLogManager.instance()?.setLogListener(self)
        
        // manager of Bluetooth devices
        btManager = BluetoothStatusManager.shared
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateStr: String = dateFormatter.string(from: Date()) + (".log")
        print("\(dateStr)")
        
        emptyEEGHistory = Array<EEGSnapshot>(repeating: EEGSnapshot.allZeros, count: maxDataPoints)
        eegHistory = emptyEEGHistory
        
        refreshViews()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*if let lastMuse = loadSavedMuse() {
            print(lastMuse)
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    // MARK: - IBAction
    
    @IBAction func disconnect(_ sender: Any) {
        if let muse = muse {
            muse.disconnect()
        }
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
    
    // MARK: - Business
    
    func loadSavedMuse() -> String? {
        
        return UserDefaults.standard.string(forKey: "lastMuse")
    }
    
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

//
//  MainViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 16/04/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, IXNMuseConnectionListener {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Main did load")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let lastMuse = loadSavedMuse() {
            print(lastMuse)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Muse
    
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
    
    // MARK: - Business
    
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

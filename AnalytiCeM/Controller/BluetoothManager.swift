//
//  BluetoothManager.swift
//  AnalytiCeM
//
//  Created by Gaël on 18/04/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import CoreBluetooth
import SCLAlertView

class BluetoothManager: NSObject, CBCentralManagerDelegate {
    
    // MARK: - Properties
    var btManager: CBCentralManager!
    
    // MARK: - Init
    override init() {
        
        super.init()
        
        // manager of Bluetooth devices
        btManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    // MARK: - CBCentralManager
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        var message: (title: String?, subtitle: String?)
        
        switch btManager!.state {
        case .poweredOff:
            message.title = "Bluetooth is off"
            message.subtitle = "Please activate Bluetooth"
            break
        case .unauthorized:
            message.title = "Not authorized"
            message.subtitle = "Please authorized Bluetooth for this application"
            break
        case .unsupported:
            message.title = "Not support"
            message.subtitle = "You will not able to fully use this application with this device"
            break
        case .resetting:
            fallthrough
        case .unknown:
            fallthrough
        case .poweredOn:
            break
        }
        
        if let title = message.title, let subtitle = message.subtitle {
            
            SCLAlertView().showError(title, subTitle: subtitle)
            
        }
    }
    
    // MARK: - Logic
    public func checkBluetooth() {
        centralManagerDidUpdateState(btManager)
    }
    
    public func isBluetoothEnabled() -> Bool {
        return btManager.state == .poweredOn
    }
    

}

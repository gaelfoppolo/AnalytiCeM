//
//  BluetoothStatusManager.swift
//  AnalytiCeM
//
//  Created by Gaël on 26/04/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import CoreBluetooth
import SCLAlertView

final class BluetoothStatusManager: NSObject, CBCentralManagerDelegate {
    
    // MARK: - Properties
    
    // shared instance
    static let shared: BluetoothStatusManager = BluetoothStatusManager()
    
    // the Bluetooth manager
    private var btManager: CBCentralManager!
    
    // current status of Bluetooth, default is unknown
    private var status: CBManagerState = .unknown {
        didSet {
            
            // notification of the changed status
            NotificationCenter.default.post(name: .bluetoothStatusChanged, object: self.status)
            
            // display error?
            if (self.shouldDisplayError) {
                self.displayError()
            }
            
        }
    }
    
    public var currentStatus: CBManagerState {
        get {
            return self.status
        }
    }
    
    // should display error on status change?
    var shouldDisplayError: Bool = true
    
    // MARK: - Init
    private override init() {
        super.init()
        // manager of Bluetooth devices
        btManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    // MARK: - CBCentralManager
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.status = central.state
    }
    
    // MARK: - Logic
    
    func displayError() {
        var message: (title: String?, subtitle: String?)
         
        switch status {
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
}

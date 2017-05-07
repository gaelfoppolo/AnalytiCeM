//
//  BluetoothStatusManager.swift
//  AnalytiCeM
//
//  Created by Gaël on 26/04/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import CoreBluetooth
import NotificationBannerSwift

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
        var message: (title: String?, subtitle: String?, style: BannerStyle?)
         
        switch status {
            case .poweredOff:
                message.title = "Bluetooth is off 👎"
                message.subtitle = "Please activate Bluetooth "
                message.style = .danger
                break
            case .unauthorized:
                message.title = "Not authorized 🚫"
                message.subtitle = "Please authorized Bluetooth for this application"
                message.style = .warning
                break
            case .unsupported:
                message.title = "Not support 😬"
                message.subtitle = "You will not able to fully use this application with this device"
                message.style = .warning
                break
            case .poweredOn:
                message.title = "Bluetooth is on 👍"
                message.subtitle = "Everything is good"
                message.style = .success
                break
            case .resetting:
                fallthrough
            case .unknown:
                break
         }
         
         if let title = message.title,
            let subtitle = message.subtitle,
            let style = message.style {
         
            let banner = NotificationBanner(title: title, subtitle: subtitle, style: style)
            banner.show()
         
         }
    }
}

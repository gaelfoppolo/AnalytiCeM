//
//  AnalytiCeMViewControllerExtension.swift
//  AnalytiCeM
//
//  Created by Gaël on 26/04/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public func registerBluetoothStatusChange(handler: @escaping (_ notification: Notification) -> ()) {
        NotificationCenter.default.addObserver(forName: Notification.Name.bluetoothStatusChanged, object: nil, queue: nil) { notification in
            handler(notification)
        }
    }
    
    public func unregisterBluetoothStatusChange() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.bluetoothStatusChanged, object: nil)
    }
    
}

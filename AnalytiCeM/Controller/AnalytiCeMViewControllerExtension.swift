//
//  AnalytiCeMViewControllerExtension.swift
//  AnalytiCeM
//
//  Created by Gaël on 26/04/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: - Notification
    
    public func registerBluetoothStatusChange(handler: @escaping (_ notification: Notification) -> ()) {
        NotificationCenter.default.addObserver(forName: Notification.Name.bluetoothStatusChanged, object: nil, queue: nil) { notification in
            handler(notification)
        }
    }
    
    public func unregisterBluetoothStatusChange() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.bluetoothStatusChanged, object: nil)
    }
    
    public func registerInternetStatusChange(handler: @escaping (_ notification: Notification) -> ()) {
        NotificationCenter.default.addObserver(forName: Notification.Name.internetStatusChanged, object: nil, queue: nil) { notification in
            handler(notification)
        }
    }
    
    public func unregisterInternetStatusChange() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.internetStatusChanged, object: nil)
    }
    
    // MARK: - Custom
    
    public func displayLogin() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.displayLogin()
    }
    
    public func displayMain() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.displayMain()
        
    }
    
}

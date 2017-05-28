//
//  AnalytiCeMViewControllerExtension.swift
//  AnalytiCeM
//
//  Created by Gaël on 26/04/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: - API Key
    
    public enum APIKey: String {
        case openWeatherMap = "OpenWeatherMap"
        
        private func keyPlist(index: String) -> String?  {
            
            guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
                let keys = NSDictionary(contentsOfFile: path) else {
                return nil
            }
            
            return keys[index] as? String
        }
        
        public func getKey() -> String? {
            return keyPlist(index: self.rawValue)
        }
        
    }
    
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

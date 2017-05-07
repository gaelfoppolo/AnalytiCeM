//
//  ConnectivityManager.swift
//  AnalytiCeM
//
//  Created by Gaël on 07/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import Foundation

import Alamofire
import NotificationBannerSwift

final class ConnectivityManager: NSObject {
    
    // MARK: - Properties
    
    // shared instance
    static let shared: ConnectivityManager = ConnectivityManager()
    
    var manager: NetworkReachabilityManager!
    
    // current status of Internet, default is false
    private var _isConnected: Bool = false {
        didSet {
            
            // notification of the changed status
            NotificationCenter.default.post(name: .internetStatusChanged, object: self._isConnected)
            
            // display error?
            if (self.shouldDisplayError) {
                self.displayError()
            }
            
        }
    }
    
    public var isConnected: Bool {
        get {
            return self._isConnected
        }
    }
    
    // should display error on status change?
    var shouldDisplayError: Bool = false
    
    // MARK: - Init
    private override init() {
        super.init()
        
        manager = NetworkReachabilityManager()
        
        manager?.listener = { status in
            
            self._isConnected = self.manager!.isReachable
        }
        
        manager?.startListening()
    }
    
    // MARK: - Logic
    
    func displayError() {
        var message: (title: String?, subtitle: String?, style: BannerStyle?)
        
        switch _isConnected {
        case false:
            message.title = "No Internet 👎"
            message.style = .danger
            break
        case true:
            message.title = "Internet 👍"
            message.subtitle = "Everything is good"
            message.style = .success
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

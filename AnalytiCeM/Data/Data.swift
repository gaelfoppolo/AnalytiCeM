//
//  Data.swift
//  AnalytiCeM
//
//  Created by Gaël on 14/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import Foundation
import RealmSwift

class Data: Object {
    
    // MARK: - Properties
    
    dynamic var timestamp: NSDate = NSDate()
    
    dynamic var eeg: Double = 0.0
    dynamic var alpha: Double = 0.0
    dynamic var beta: Double = 0.0
    dynamic var delta: Double = 0.0
    dynamic var gamma: Double = 0.0
    dynamic var theta: Double = 0.0
    
    dynamic var blinkCount: Int = 0
    dynamic var jawCount: Int = 0
    
    dynamic var gps: GPS?
    
    // MARK: - Initializers
    
    convenience init(timestamp: NSDate,
                     eeg: Double,
                     alpha: Double,
                     beta: Double,
                     delta: Double,
                     gamma: Double,
                     theta: Double,
                     blinkCount: Int,
                     jawCount: Int,
                     gps: GPS) {
        self.init()
        self.timestamp = timestamp
        self.eeg = eeg
        self.alpha = alpha
        self.beta = beta
        self.delta = delta
        self.gamma = gamma
        self.theta = theta
        self.blinkCount = blinkCount
        self.jawCount = jawCount
        self.gps = gps
    }
}

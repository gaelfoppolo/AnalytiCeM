//
//  WeatherManager.swift
//  AnalytiCeM
//
//  Created by Gaël on 07/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import Foundation

final class WeatherManager: NSObject {
    
    // MARK: - Properties
    var current: WeatherResult?
    
    // MARK: - Init
    private override init() {
        super.init()
        // todo:
        // LocationManager
        // timer to retrieve Weather each 30min
        // delegate: weather available, launching new retrieve
    }
    
}

//
//  Weather.swift
//  AnalytiCeM
//
//  Created by Gaël on 07/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import SwiftyJSON
import RealmSwift

class Weather: Object {
    
    // MARK: - Properties
    
    dynamic var condition: String = ""
    dynamic var temperature: Double = 0
    dynamic var icon: String = ""
    
    convenience init(json: JSON) {
        self.init()
        
        self.condition = json["weather"][0]["main"].string ?? ""
        self.temperature = json["main"]["temp"].double ?? 0
        self.icon = json["weather"][0]["icon"].string ?? ""
    }
}

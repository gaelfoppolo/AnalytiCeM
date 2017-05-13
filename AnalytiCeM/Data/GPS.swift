//
//  GPS.swift
//  AnalytiCeM
//
//  Created by Gaël on 14/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import Foundation
import MapKit

import RealmSwift

class GPS: Object {
    
    // MARK: - Properties
    
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    
    // Computed properties are ignored in Realm
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}

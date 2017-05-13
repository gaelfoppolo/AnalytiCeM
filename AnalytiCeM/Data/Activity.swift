//
//  Activity.swift
//  AnalytiCeM
//
//  Created by Gaël on 13/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import Foundation
import RealmSwift

class Activity: Object {
    
    dynamic var id: Int = 0
    dynamic var label: String = ""
    let types = List<ActivityType>()
    dynamic var mentalState: MentalState?
    
    // MARK: - Initializers
    
    convenience init(label: String,
                     types: Set<ActivityType>,
                     mentalState: MentalState) {
        self.init()
        self.id = Activity.incrementID()
        types.forEach { (at) in
            self.types.append(at)
        }
        self.mentalState = mentalState
    }
    
    // MARK: - Realm
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: - Helper
    private static func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(Activity.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    
}

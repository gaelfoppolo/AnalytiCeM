//
//  Session.swift
//  AnalytiCeM
//
//  Created by Gaël on 14/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import Foundation
import RealmSwift

class Session: Object {
    
    // MARK: - Properties
    
    dynamic var id: Int = 0
    
    dynamic var start: NSDate = NSDate()
    dynamic var end: NSDate? = nil
    
    dynamic var user: User?
    dynamic var weather: Weather?
    dynamic var activity: Activity?
    
    let data = List<Data>()
    
    // MARK: - Initializers
    
    convenience init(start: NSDate,
                     user: User,
                     weather: Weather,
                     activity: Activity) {
        self.init()
        self.id = Session.incrementID()
        self.start = start
        self.user = user
        self.weather = weather
        self.activity = activity
    }
    
    // MARK: - Realm
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: - Helper
    private static func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(Session.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    
}

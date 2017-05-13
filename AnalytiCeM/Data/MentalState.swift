//
//  MentalState.swift
//  AnalytiCeM
//
//  Created by Gaël on 13/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import Foundation
import RealmSwift

class MentalState: Object {
    
    dynamic var id: Int = 0
    dynamic var label: String = ""
    
    // MARK: - Initializers
    
    convenience init(label: String) {
        self.init()
        self.id = MentalState.incrementID()
        self.label = label
    }
    
    // MARK: - Realm
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: - Helper
    private static func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(MentalState.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    // MARK: - CustomStringConvertible
    
    override var description: String { return label }
}

//
//  Muse.swift
//  AnalytiCeM
//
//  Created by Gaël on 22/04/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import RealmSwift

class Muse: Object {
    
    // MARK: - Properties
    
    private dynamic var id: Int = 0
    private dynamic var name: String? = nil
    private let remaningBattery = RealmOptional<Double>()
    
    // MARK: - Initializers
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func getName() -> String? {
        return self.name
    }

    func getBattery() -> Double? {
        return self.remaningBattery.value
    }

}

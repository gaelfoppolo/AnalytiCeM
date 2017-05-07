//
//  Muse.swift
//  AnalytiCeM
//
//  Created by Gaël on 22/04/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import RealmSwift

class Muse: Object {
    
    // MARK: - Properties
    
    private dynamic var name: String = ""
    private dynamic var isCurrent: Bool = false
    
    // MARK: - Initializers
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    // MARK: - Getters
    
    func getName() -> String? {
        return self.name
    }
    
    func getStatus() -> Bool {
        return self.isCurrent
    }
    
    // MARK: - Setters
    
    func setAsCurrent(_ val: Bool) {
        Muse.resetCurrent()
        self.isCurrent = val
    }
    
    // MARK: - Helper
    
    private static func resetCurrent() {
        let realm = try! Realm()
        realm.objects(Muse.self).forEach({ muse in
            muse.isCurrent = false
        })
    }

}

//
//  User.swift
//  AnalytiCeM
//
//  Created by Gaël on 01/05/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import RealmSwift

class User: Object {
    
    // MARK: - Properties
    
    private dynamic var id: Int = 0
    private dynamic var email: String = ""
    private dynamic var password: String = ""
    private dynamic var salt: String = ""
    
    private dynamic var firstName: String = ""
    private dynamic var lastName: String = ""
    private dynamic var birth: Date = Date()
    
    private dynamic var gender: String = ""
    private dynamic var weight: Int = 0
    private dynamic var size: Int = 0
    
    private dynamic var isCurrent: Bool = false
    
    // MARK: - Initializers
    
    convenience init(email: String,
                    password: String,
                    salt: String,
                    firstName: String,
                    lastName: String,
                    birth: Date,
                    gender: String,
                    weight: Int,
                    size: Int) {
        self.init()
        self.id = User.incrementID()
        self.email = email
        self.password = password
        self.salt = salt
        self.firstName = firstName
        self.lastName = lastName
        self.birth = birth
        self.gender = gender
        self.weight = weight
        self.size = size
    }
    
    // MARK: - Realm
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    /*override static func indexedProperties() -> [String] {
        return []
    }
    
    override static func ignoredProperties() -> [String] {
        return []
    }*/
    
    // MARK: - Getters
    
    func getStatus() -> Bool {
        return self.isCurrent
    }
    
    // MARK: - Setters
    
    func setAsCurrent() {
        User.resetCurrent()
        self.isCurrent = true
    }
    
    // MARK: - Helper
    
    private static func resetCurrent() {
        let realm = try! Realm()
        realm.objects(User.self).forEach({ user in
            user.isCurrent = false
        })
    }
    
    private static func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(User.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
}

//
//  FillRealm.swift
//  AnalytiCeM
//
//  Created by Gaël on 13/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import Foundation
import RealmSwift

class FillRealm {
    static func defaults() {
        
        let realm = try! Realm()
        // only at first startup
        guard realm.isEmpty else {return}
        
        try! realm.write {
            
            realm.add(ActivityType(label: "Entertainment"))
            realm.add(ActivityType(label: "Sport"))
            realm.add(ActivityType(label: "Reading"))
            realm.add(ActivityType(label: "Sleeping"))
            realm.add(ActivityType(label: "Napping"))
            realm.add(ActivityType(label: "Hanging out"))
            realm.add(ActivityType(label: "Revising"))
            realm.add(ActivityType(label: "Learning"))
            realm.add(ActivityType(label: "Traveling"))
            realm.add(ActivityType(label: "Visiting"))
            
            realm.add(MentalState(label: "Relaxed"))
            realm.add(MentalState(label: "Hungry"))
            realm.add(MentalState(label: "Tired"))
            realm.add(MentalState(label: "Angry"))
            realm.add(MentalState(label: "Stressed"))
            realm.add(MentalState(label: "Sad"))
            realm.add(MentalState(label: "Happy"))
            realm.add(MentalState(label: "Feared"))
            realm.add(MentalState(label: "Worried"))
            realm.add(MentalState(label: "Drunk"))
            realm.add(MentalState(label: "Depressed"))
            realm.add(MentalState(label: "Anxious"))
            realm.add(MentalState(label: "In love"))
            

        }
        
    }
}

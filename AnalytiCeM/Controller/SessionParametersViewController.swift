//
//  SessionParametersViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 13/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

import Eureka

class SessionParametersViewController: FormViewController {
    
    // MARK: - Properties
    
    let kSectionTagSession = "session"
    let kSectionSessionTagLabel = "session.label"
    let kSectionSessionTagActivityType = "session.activity"
    let kSectionSessionTagMentalState = "session.mental"

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func setupUI() {
        
        // create the section
        let section = Section()
        section.tag = kSectionTagSession
        
        // add the section
        form +++ section
        
        // label
        section <<< TextRow() {
            $0.title = "Your activity"
            $0.placeholder = "Hiking"
            $0.tag = kSectionSessionTagLabel
        }
        
        <<< MultipleSelectorRow<String>() {
            $0.title = "Your activity type"
            $0.options = ["💁🏻", "🍐", "👦🏼", "🐗", "🐼", "🐻"]
            $0.value = ["👦🏼", "🍐", "🐗"]
            $0.tag = kSectionSessionTagActivityType
        }
        
    }

}

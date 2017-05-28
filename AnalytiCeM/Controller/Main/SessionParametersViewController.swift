//
//  SessionParametersViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 13/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

import Eureka
import RealmSwift

protocol ActivityParameterDelegate {
    
    func didChoose(parameters activity: Activity)
    
}

class SessionParametersViewController: FormViewController {
    
    // MARK: - Properties
    
    let kSectionTagActivity = "activity"
    let kSectionActivityTagLabel = "activity.label"
    
    let kSectionTagActivityType = "activityType"
    let kSectionActivityTypeTagLabel = "activityType.label"
    
    let kSectionTagMentalState = "mentalState"
    let kSectionMentalStateTagLabel = "mentalState.label"
    
    let kSectionTagValidate = "validate"
    let kSectionValidateTagRegister = "validate.label"
    
    let realm = try! Realm()
    
    var delegate: ActivityParameterDelegate?

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
        
        TextRow.defaultOnRowValidationChanged = { cell, row in
            let rowIndex = row.indexPath!.row
            while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                row.section?.remove(at: rowIndex + 1)
            }
            if !row.isValid {
                let labelRow = LabelRow() {
                    $0.title = "Please type your activity"
                    $0.cell.height = { 30 }
                    $0.cell.backgroundColor = .red
                }
                row.section?.insert(labelRow, at: row.indexPath!.row + 1)
            }
        }
        
        MultipleSelectorRow<ActivityType>.defaultOnRowValidationChanged = { cell, row in
            let rowIndex = row.indexPath!.row
            while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                row.section?.remove(at: rowIndex + 1)
            }
            if !row.isValid {
                let labelRow = LabelRow() {
                    $0.title = "Please choose at least one category"
                    $0.cell.height = { 30 }
                    $0.cell.backgroundColor = .red
                }
                row.section?.insert(labelRow, at: row.indexPath!.row + 1)
            }
        }
        
        PushRow<MentalState>.defaultOnRowValidationChanged = { cell, row in
            let rowIndex = row.indexPath!.row
            while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                row.section?.remove(at: rowIndex + 1)
            }
            if !row.isValid {
                let labelRow = LabelRow() {
                    $0.title = "Please choose a mental state"
                    $0.cell.height = { 30 }
                    $0.cell.backgroundColor = .red
                }
                row.section?.insert(labelRow, at: row.indexPath!.row + 1)
            }
        }
        
        // create the section activity
        let sectionActivity = Section(header: "What is your activity?", footer: "Should be between 2 and 15 characters")
        sectionActivity.tag = kSectionTagActivity
        
        // add the section
        form +++ sectionActivity
        
        // label
        sectionActivity <<< TextRow() {
            $0.placeholder = "Hiking"
            // rules
            $0.add(rule: RuleRequired())
            $0.add(rule: RuleMinLength(minLength: 2))
            $0.add(rule: RuleMaxLength(maxLength: 15))
            // tag
            $0.tag = kSectionActivityTagLabel
        }
        
        // create the section activity type
        let sectionActivityType = Section("What kind of activity is it?")
        sectionActivityType.tag = kSectionTagActivityType
        
        // add the section
        form +++ sectionActivityType
            
        // activity type
        sectionActivityType <<< MultipleSelectorRow<ActivityType>() { (row : MultipleSelectorRow<ActivityType>) -> Void in
            
            row.options = []
            
            // get activity types
            let activityTypes = realm.objects(ActivityType.self)
            activityTypes.forEach({ at in
                row.options.append(at)
            })
            
            row.displayValueFor = { (rowValue: Set<ActivityType>?) in
                return rowValue?.map({ $0.label }).sorted().joined(separator: ", ")
            }
            
            // rules
            row.add(rule: RuleRequired())
            // tag
            
            row.tag = kSectionActivityTypeTagLabel
        }
        
        // create the section mental state
        let sectionMentalState = Section("What's your current mood?")
        sectionMentalState.tag = kSectionTagMentalState
        
        // add the section
        form +++ sectionMentalState
            
        sectionMentalState <<< PushRow<MentalState>() { (row : PushRow<MentalState>) -> Void in
            row.options = []
            
            // get mental state
            let mentalStates = realm.objects(MentalState.self)
            mentalStates.forEach({ ms in
                row.options.append(ms)
            })
            
            row.displayValueFor = { (rowValue: MentalState?) in
                return rowValue?.label
            }
            
            // rules
            row.add(rule: RuleRequired())
            // tag
            
            row.tag = kSectionMentalStateTagLabel
        }
        
        // create the section validate
        let validateSection = Section()
        validateSection.tag = kSectionTagValidate
        
        // add the section displaying the account section to the form
        form +++ validateSection
        
        validateSection <<< ButtonRow() {
            $0.title = "Start session"
            $0.tag = kSectionValidateTagRegister
            }
            .onCellSelection { cell, row in
                
                let errors = self.form.validate()
                
                // no error, then validate
                if errors.count == 0 {
                    
                    self.validate()
                }
        }
        
    }
    
    private func validate() {
        
        // if delegate
        if (self.delegate != nil) {
            
            // retrieve values
            let labelValue = (form.rowBy(tag: kSectionActivityTagLabel) as! TextRow).value!
            let activityTypes = (form.rowBy(tag: kSectionActivityTypeTagLabel) as! MultipleSelectorRow<ActivityType>).value!
            let mentalStateValue = (form.rowBy(tag: kSectionMentalStateTagLabel) as! PushRow<MentalState>).value!
            
            let activity = Activity(label: labelValue,
                                    types: activityTypes,
                                    mentalState: mentalStateValue
            )
            
            // call delegate
            self.delegate!.didChoose(parameters: activity)
            
        }
        
    }

}

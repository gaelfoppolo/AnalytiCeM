//
//  UserProfileViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 02/05/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import Eureka
import UIKit

class UserProfileViewController: FormViewController {
    
    // MARK: - Properties
    
    let kSectionTagAccount = "account"
    let kSectionAccountTagEmail = "account.email"
    let kSectionAccountTagPassword = "account.password"
    
    let kSectionTagUser = "user"
    let kSectionUserTagFirstName = "user.firstName"
    let kSectionUserTagLastName = "user.lastName"
    let kSectionUserTagBirthday = "user.birthday"
    let kSectionUserTagGender = "user.gender"
    let kSectionUserTagWeight = "user.weight"
    let kSectionUserTagSize = "user.size"
    
    let kSectionTagValidate = "validate"
    let kSectionValidateTagRegister = "validate.register"
    
    let kMinLenghtName: UInt = 2
    let kMaxLenghtName: UInt = 15
    
    let kMinLenghtPassword: UInt = 6
    let kMaxLenghtPassword: UInt = 15
    
    let kMaxAge: Int = 100
    
    let kMinWeight: Int = 40
    let kMaxWeight: Int = 150
    
    let kMinSize: Int = 100
    let kMaxSize: Int = 220
    
    let dateFormatter = DateFormatter()
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dateFormatter.locale = .current
        self.dateFormatter.dateStyle = .long
        
        setupUI()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        
        // create the section account
        let accountSection = Section(header: "Account", footer: "Password should be between 6 and 15 characters")
        accountSection.tag = kSectionTagAccount
        
        // add the section displaying the account section to the form
        form +++ accountSection
        
        // email
        accountSection  <<< EmailRow() {
            $0.title = "Email"
            $0.placeholder = "you@mail.com"
            $0.add(rule: RuleEmail())
            $0.tag = kSectionAccountTagEmail
        }
            
        // password
        <<< PasswordRow() {
            $0.title = "Password"
            // rules
            $0.add(rule: RuleMinLength(minLength: kMinLenghtPassword))
            $0.add(rule: RuleMaxLength(maxLength: kMaxLenghtPassword))
            $0.tag = kSectionAccountTagPassword
        }
            
        <<< PasswordRow() {
           $0.title = "Confirm password"
           $0.add(rule: RuleEqualsToRow(form: form, tag: kSectionAccountTagPassword))
        }
            
        // create the section user
        let userSection = Section("User")
        userSection.tag = kSectionTagUser
        
        // add the section displaying the account section to the form
        form +++ userSection
        
        // first name
        <<< TextRow() {
            $0.title = "First name"
            $0.placeholder = "Jon"
            // rules
            $0.add(rule: RuleMinLength(minLength: kMinLenghtName))
            $0.add(rule: RuleMaxLength(maxLength: kMaxLenghtName))
            $0.tag = kSectionUserTagFirstName
        }
        
        // last name
        <<< TextRow() {
            $0.title = "Last name"
            $0.placeholder = "Snow"
            // rules
            $0.add(rule: RuleMinLength(minLength: kMinLenghtName))
            $0.add(rule: RuleMaxLength(maxLength: kMaxLenghtName))
            $0.tag = kSectionUserTagLastName
        }
        
        // birthday
        <<< DateRow(){
            $0.title = "Birthday"
            $0.value = Date()
            $0.tag = kSectionUserTagBirthday
            // formatter
            $0.dateFormatter = self.dateFormatter
            // rules
            var ruleSet = RuleSet<Date>()
            // before today
            ruleSet.add(rule: RuleSmallerThan(max: Date()))
            // after kMaxAge years before today
            let oneHundredYearBefore = Calendar.current.date(byAdding: .year, value: -kMaxAge, to: Date())
            ruleSet.add(rule: RuleGreaterThan(min: oneHundredYearBefore!))
            $0.add(ruleSet: ruleSet)
        }
        
        // gender
        <<< SegmentedRow<String>(){
            $0.title = "Gender"
            $0.options = ["M","F"]
        }
        
        // weight
        <<< PickerInlineRow<Int>() { (row : PickerInlineRow<Int>) -> Void in
            row.title = "Weight"
            row.displayValueFor = { (rowValue: Int?) in
                return rowValue.map { "\($0) kg" }
            }
            row.options = []
            var weight = kMinWeight
            while weight <= kMaxWeight {
                row.options.append(weight)
                weight += 1
            }
            row.tag = kSectionUserTagWeight
        }
        
        // size
        <<< PickerInlineRow<Int>() { (row : PickerInlineRow<Int>) -> Void in
            row.title = "Size"
            row.displayValueFor = { (rowValue: Int?) in
                return rowValue.map { "\($0) cm" }
            }
            row.options = []
            var size = kMinSize
            while size <= kMaxSize {
                row.options.append(size)
                size += 1
            }
            row.tag = kSectionUserTagSize
        }

        // create the section validate
        let validateSection = Section()
        validateSection.tag = kSectionTagValidate
        
        // add the section displaying the account section to the form
        form +++ validateSection
        
        validateSection <<< ButtonRow() {
            $0.title = "Register"
            $0.tag = kSectionValidateTagRegister
        }
        .onCellSelection { cell, row in
            row.section?.form?.validate()
            let errors = self.form.validate()
            errors.forEach({error in
                print(error)
            })
        }
    }    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

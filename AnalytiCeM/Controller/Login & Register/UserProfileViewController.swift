//
//  UserProfileViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 02/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import Eureka
import RealmSwift

import UIKit

protocol UserProfileDelegate {
    
    func validate(user: UserProfil)
    
}

typealias UserProfil = (
                        email: String,
                        oldPassword: String?,
                        password: String?,
                        firstName: String,
                        lastName: String,
                        birthday: Date,
                        gender: String,
                        weight: Int,
                        size: Int
                        )

class UserProfileViewController: FormViewController {
    
    // MARK: - Properties
    
    let kSectionTagAccount = "account"
    let kSectionAccountTagEmail = "account.email"
    let kSectionAccountTagCurrentPassword = "account.currentPassword"
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
    
    var editionMode: Bool = false
    
    var delegate: UserProfileDelegate?
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dateFormatter.locale = .current
        self.dateFormatter.dateStyle = .long
        
        setupUI()
        
        if editionMode {
            fill()
        }

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
        
        // default on update
        EmailRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }
        EmailRow.defaultOnRowValidationChanged = { cell, row in
            let rowIndex = row.indexPath!.row
            while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                row.section?.remove(at: rowIndex + 1)
            }
            if !row.isValid {
                let labelRow = LabelRow() {
                    $0.title = row.validationErrors.first?.msg
                    $0.cell.height = { 30 }
                    $0.cell.backgroundColor = .red
                }
                row.section?.insert(labelRow, at: row.indexPath!.row + 1)
            }
        }
        
        PasswordRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }
        PasswordRow.defaultOnRowValidationChanged = { cell, row in
            let rowIndex = row.indexPath!.row
            while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                row.section?.remove(at: rowIndex + 1)
            }
            if !row.isValid {
                let labelRow = LabelRow() {
                    $0.title = row.validationErrors.first?.msg
                    $0.cell.height = { 30 }
                    $0.cell.backgroundColor = .red
                }
                row.section?.insert(labelRow, at: row.indexPath!.row + 1)
            }
        }
        
        TextRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }
        TextRow.defaultOnRowValidationChanged = { cell, row in
            let rowIndex = row.indexPath!.row
            while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                row.section?.remove(at: rowIndex + 1)
            }
            if !row.isValid {
                let labelRow = LabelRow() {
                    $0.title = row.validationErrors.first?.msg
                    $0.cell.height = { 30 }
                    $0.cell.backgroundColor = .red
                }
                row.section?.insert(labelRow, at: row.indexPath!.row + 1)
            }
        }
        
        DateRow.defaultOnRowValidationChanged = { cell, row in
            let rowIndex = row.indexPath!.row
            while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                row.section?.remove(at: rowIndex + 1)
            }
            if !row.isValid {
                let labelRow = LabelRow() {
                    $0.title = "The date is not valid"
                    $0.cell.height = { 30 }
                    $0.cell.backgroundColor = .red
                }
                row.section?.insert(labelRow, at: row.indexPath!.row + 1)
            }
        }
        
        SegmentedRow<String>.defaultOnRowValidationChanged = { cell, row in
            let rowIndex = row.indexPath!.row
            while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                row.section?.remove(at: rowIndex + 1)
            }
            if !row.isValid {
                let labelRow = LabelRow() {
                    $0.title = "Please select a gender"
                    $0.cell.height = { 30 }
                    $0.cell.backgroundColor = .red
                }
                row.section?.insert(labelRow, at: row.indexPath!.row + 1)
            }
        }
        
        PickerInlineRow<Int>.defaultOnRowValidationChanged = { cell, row in
            let rowIndex = row.indexPath!.row
            while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                row.section?.remove(at: rowIndex + 1)
            }
            if !row.isValid {
                let labelRow = LabelRow() {
                    $0.title = "Please choose a value"
                    $0.cell.height = { 30 }
                    $0.cell.backgroundColor = .red
                }
                row.section?.insert(labelRow, at: row.indexPath!.row + 1)
            }
        }
        
        // email
        accountSection <<< EmailRow() { (row : EmailRow) -> Void in
            row.title = "Email"
            row.placeholder = "you@mail.com"
            // rules
            row.add(rule: RuleEmail())
            row.add(rule: RuleRequired())
            let ruleCheckEmailViaClosure = RuleClosure<String> { rowValue in
                
                // there is a value
                // and no other error
                guard let email = rowValue, !email.isEmpty, (row.validationErrors.count == 0) else {
                    return nil
                }
                
                // get users with that mail & not current user
                let realm = try! Realm()
                let usersMatching = realm.objects(User.self).filter("email == %@", email).filter("isCurrent == false")
                
                // if there is
                if (usersMatching.count != 0) {
                    return ValidationError(msg: "This email is already taken")
                }
                
                return nil
            }
            row.add(rule: ruleCheckEmailViaClosure)
            row.tag = kSectionAccountTagEmail
        }
        
        // edit the profil
        if editionMode {
            
            // old password
            accountSection <<< PasswordRow() {
                $0.title = "Current password"
                // rules
                $0.add(rule: RuleMinLength(minLength: kMinLenghtPassword))
                $0.add(rule: RuleMaxLength(maxLength: kMaxLenghtPassword))
                $0.add(rule: RuleRequired())
                $0.tag = kSectionAccountTagCurrentPassword
            }
        }
            
        // password
        accountSection <<< PasswordRow() {
            
            // edit profil
            if editionMode {
                $0.title = "New password"
            }
            else {
                $0.title = "Password"
                $0.add(rule: RuleRequired())
            }
            
            // rules
            $0.add(rule: RuleMinLength(minLength: kMinLenghtPassword))
            $0.add(rule: RuleMaxLength(maxLength: kMaxLenghtPassword))
            $0.tag = kSectionAccountTagPassword
        }
            
        <<< PasswordRow() {
            
            // edit profil
            if editionMode {
                $0.title = "Confirm new password"
            }
            else {
                $0.title = "New password"
            }
            
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
            $0.add(rule: RuleRequired())
            $0.tag = kSectionUserTagFirstName
        }
        
        // last name
        <<< TextRow() {
            $0.title = "Last name"
            $0.placeholder = "Snow"
            // rules
            $0.add(rule: RuleMinLength(minLength: kMinLenghtName))
            $0.add(rule: RuleMaxLength(maxLength: kMaxLenghtName))
            $0.add(rule: RuleRequired())
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
            ruleSet.add(rule: RuleRequired())
            ruleSet.add(rule: RuleGreaterThan(min: oneHundredYearBefore!))
            $0.add(ruleSet: ruleSet)
        }
        
        // gender
        <<< SegmentedRow<String>(){
            $0.title = "Gender"
            $0.options = ["M","F"]
            $0.add(rule: RuleRequired())
            $0.tag = kSectionUserTagGender
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
            // rule
            row.add(rule: RuleRequired())
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
            // rule
            row.add(rule: RuleRequired())
        }

        // create the section validate
        let validateSection = Section()
        validateSection.tag = kSectionTagValidate
        
        // add the section displaying the account section to the form
        form +++ validateSection
        
        validateSection <<< ButtonRow() {
            
            // edit profile
            if editionMode {
                $0.title = "Update"
            }
            else {
                $0.title = "Register"
            }
            
            $0.tag = kSectionValidateTagRegister
        }
        .onCellSelection { cell, row in
            
            let errors = self.form.validate()
            
            // no error, then validate
            if errors.count == 0 {
                
                // edition -> update
                if self.editionMode {
                    self.validateUpdate()
                }
                // creation -> register
                else {
                    self.validateRegister()
                }
            }
        }
    }
    
    /*override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.topLayoutGuide.co = self.parent?.topLayoutGuide.length
    }*/

    private func fill() {
        
        // get the current user
        let realm = try! Realm()
        let currentUser = realm.objects(User.self).filter("isCurrent == true").first
        
        // fill rows
        (form.rowBy(tag: kSectionAccountTagEmail) as! EmailRow).value = currentUser?.email
        (form.rowBy(tag: kSectionUserTagFirstName) as! TextRow).value = currentUser?.firstName
        (form.rowBy(tag: kSectionUserTagLastName) as! TextRow).value = currentUser?.lastName
        (form.rowBy(tag: kSectionUserTagBirthday) as! DateRow).value = currentUser?.birth
        (form.rowBy(tag: kSectionUserTagGender) as! SegmentedRow<String>).value = currentUser?.gender
        (form.rowBy(tag: kSectionUserTagWeight) as! PickerInlineRow<Int>).value = currentUser?.weight
        (form.rowBy(tag: kSectionUserTagSize) as! PickerInlineRow<Int>).value = currentUser?.size
        
    }
    
    private func validateRegister() {
    
        // if delegate
        if (self.delegate != nil) {
            
            // retrieve values
            let emailValue = (form.rowBy(tag: kSectionAccountTagEmail) as! EmailRow).value!
            let passwordValue = (form.rowBy(tag: kSectionAccountTagPassword) as! PasswordRow).value
            let firstNameValue = (form.rowBy(tag: kSectionUserTagFirstName) as! TextRow).value!
            let lastNameValue = (form.rowBy(tag: kSectionUserTagLastName) as! TextRow).value!
            let birthdayValue = (form.rowBy(tag: kSectionUserTagBirthday) as! DateRow).value!
            let genderValue = (form.rowBy(tag: kSectionUserTagGender) as! SegmentedRow<String>).value!
            let weightValue = (form.rowBy(tag: kSectionUserTagWeight) as! PickerInlineRow<Int>).value!
            let sizeValue = (form.rowBy(tag: kSectionUserTagSize) as! PickerInlineRow<Int>).value!
            
            let userProfil: UserProfil = (email: emailValue,
                                        oldPassword: nil,
                                        password: passwordValue,
                                        firstName: firstNameValue,
                                        lastName: lastNameValue,
                                        birthday: birthdayValue,
                                        gender: genderValue,
                                        weight: weightValue,
                                        size: sizeValue)
            
            // call delegate
            self.delegate!.validate(user: userProfil)
            
        }
        
    }
    
    private func validateUpdate() {
        
        // if delegate
        if (self.delegate != nil) {
            
            // retrieve values
            let emailValue = (form.rowBy(tag: kSectionAccountTagEmail) as! EmailRow).value!
            let oldPasswordValue = (form.rowBy(tag: kSectionAccountTagCurrentPassword) as! PasswordRow).value
            let passwordValue = (form.rowBy(tag: kSectionAccountTagPassword) as! PasswordRow).value
            let firstNameValue = (form.rowBy(tag: kSectionUserTagFirstName) as! TextRow).value!
            let lastNameValue = (form.rowBy(tag: kSectionUserTagLastName) as! TextRow).value!
            let birthdayValue = (form.rowBy(tag: kSectionUserTagBirthday) as! DateRow).value!
            let genderValue = (form.rowBy(tag: kSectionUserTagGender) as! SegmentedRow<String>).value!
            let weightValue = (form.rowBy(tag: kSectionUserTagWeight) as! PickerInlineRow<Int>).value!
            let sizeValue = (form.rowBy(tag: kSectionUserTagSize) as! PickerInlineRow<Int>).value!
            
            let userProfil: UserProfil = (email: emailValue,
                                          oldPassword: oldPasswordValue,
                                          password: passwordValue,
                                          firstName: firstNameValue,
                                          lastName: lastNameValue,
                                          birthday: birthdayValue,
                                          gender: genderValue,
                                          weight: weightValue,
                                          size: sizeValue)
            
            // call delegate
            self.delegate!.validate(user: userProfil)
            
        }
    }

}

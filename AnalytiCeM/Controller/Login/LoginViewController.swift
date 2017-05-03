//
//  LoginViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 01/05/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import Eureka
import RealmSwift
import SwiftSpinner

import UIKit

class LoginViewController: FormViewController {
    
    // MARK: - Properties
    
    let kSectionTagLogin = "login"
    let kSectionLoginTagEmail = "login.email"
    let kSectionLoginTagPassword = "login.password"
    
    let kSectionTagValidate = "validate"
    let kSectionValidateTagLogin = "validate.login"
    
    let kSectionTagRegister = "register"
    let kSectionRegisterTagLoad = "register.load"
    
    var passwordManager: PasswordManager!
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // name is explicite enough
        passwordManager = PasswordManager.shared
        
        setupUI()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        
        // navigation bar
        self.navigationItem.title = "Login"
        
        // get users
        let realm = try! Realm()
        let users = realm.objects(User.self)
        
        // no user
        // then only display register button
        if (users.count != 0) {
        
            // create the section login
            let loginSection = Section("Login")
            loginSection.tag = kSectionTagLogin
            
            // add the section displaying the login section to the form
            form +++ loginSection
            
            PasswordRow.defaultCellUpdate = { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
            
            // email
            loginSection <<< PickerInlineRow<User>() { (row : PickerInlineRow<User>) -> Void in
                row.title = "Email"
                row.options = []
                row.displayValueFor = { (rowValue: User?) in
                    return rowValue?.email
                }
                // get users
                let realm = try! Realm()
                let users = realm.objects(User.self)
                users.forEach({ user in
                    row.options.append(user)
                })
                // pre-select
                row.value = row.options[0]
                // tag
                row.tag = kSectionLoginTagEmail
                // rule
                row.add(rule: RuleRequired())
                }
                
                // password
                <<< PasswordRow() { (row : PasswordRow) -> Void in
                    row.title = "Password"
                    // rules
                    row.add(rule: RuleRequired())
                    row.tag = kSectionLoginTagPassword
            }
            
            // create the section validate
            let validateSection = Section()
            validateSection.tag = kSectionTagValidate
            
            // add the section displaying the account section to the form
            form +++ validateSection
            
            validateSection <<< ButtonRow() {
                $0.title = "Login"
                $0.tag = kSectionValidateTagLogin
                }
                .onCellSelection { cell, row in
                    
                    let errors = self.form.validate()
                    
                    // no error, then try login
                    if errors.count == 0 {
                        
                        // try to login
                        self.tryLogin()

                    }
                }
        
        }
        
        // create the section register
        let registerSection = Section()
        registerSection.tag = kSectionTagRegister
        
        // add the section displaying the register view
        form +++ registerSection
        
        registerSection <<< ButtonRow() {
            $0.title = "Register"
            $0.tag = kSectionRegisterTagLoad
        }
        .onCellSelection { cell, row in
                
            // display the view register
            let registerViewController = RegisterViewController(nibName: "RegisterViewController", bundle: nil)
            self.navigationController?.pushViewController(registerViewController, animated: true)
            
        }
        
    }
    
    private func tryLogin() {
        
        SwiftSpinner.show("Login..")
        
        // get user and supposed password
        let user = (self.form.rowBy(tag: self.kSectionLoginTagEmail) as! PickerInlineRow<User>).value!
        let tryPassword = (self.form.rowBy(tag: self.kSectionLoginTagPassword) as! PasswordRow).value!
        
        // get valid value
        let currentPassword = user.password
        let currentSalt = user.salt
        
        // compute password in background
        // because password hashing may be heavy operation
        DispatchQueue.global(qos: .background).async {
            
            // try to verify
            let passwordIsValid = self.passwordManager.verifyPassword(tryPassword: tryPassword, salt: currentSalt, correctPassword: currentPassword)
            
            // verification succeed
            if let passwordIsValid = passwordIsValid, passwordIsValid {
                
                DispatchQueue.main.async {
                    
                    // set as current
                    let realm = try! Realm()
                    try! realm.write {
                        user.setAsCurrent()
                    }

                    // add view with dismissal after a sec
                    SwiftSpinner.show(duration: 1, title: "Success", animated: false)
                    
                    // remove view, login is done
                    self.dismiss(animated: true, completion: nil)
                    
                }
                
            } else {
                
                // dismiss view
                DispatchQueue.main.async {
                
                    // add view with dismissal after a sec
                    SwiftSpinner.show(duration: 1, title: "Wrong\npassword", animated: false)
                }
            }
                
        }
        
    }

}

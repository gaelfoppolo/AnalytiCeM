//
//  LoginViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 01/05/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import CryptoSwift
import Eureka
import RealmSwift

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
                    
                    // remove
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    
                    let errors = self.form.validate()
                    
                    // no error, then try login
                    if errors.count == 0 {
                        
                        // get email
                        let user = (self.form.rowBy(tag: self.kSectionLoginTagEmail) as! PickerInlineRow<User>).value!
                        let passwordValue = (self.form.rowBy(tag: self.kSectionLoginTagPassword) as! PasswordRow).value!
                        
                        let currentPassword = user.password
                        let currentSalt = user.salt
                        
                        // compute password in background
                        // because password hashingmay be heavy operation
                        DispatchQueue.global(qos: .background).async {
                            do {
                                
                                let password: Array<UInt8> = Array(passwordValue.utf8)
                                let salt: Array<UInt8> = Array(currentSalt.utf8)
                                
                                let passwordCryptedRaw = try PKCS5.PBKDF2(password: password, salt: salt, iterations: 4096, variant: .sha512).calculate()
                                
                                // export has readable string
                                let passwordCrypted = passwordCryptedRaw.toHexString()
                                
                                DispatchQueue.main.async {
                                
                                    // compare
                                    if passwordCrypted == currentPassword {
                                    
                                        // set as current
                                        let realm = try! Realm()
                                        try! realm.write {
                                            user.setAsCurrent()
                                        }
                                        // remove view, registration is done
                                        self.dismiss(animated: true, completion: nil)
                                    
                                    } else {
                                        
                                        let labelRow = LabelRow() {
                                            $0.title = "Wrong password"
                                            $0.cell.height = { 30 }
                                            $0.cell.backgroundColor = .red
                                        }
                                        row.section?.insert(labelRow, at: row.indexPath!.row + 1)
                                        
                                    }
                                }
                                
                            } catch let error {
                                print(error)
                                fatalError()
                            }
                        }

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

}

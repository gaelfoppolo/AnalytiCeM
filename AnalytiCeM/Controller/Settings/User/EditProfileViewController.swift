//
//  EditProfileViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 25/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import RealmSwift
import SwiftSpinner

import UIKit

class EditProfileViewController: UIViewController, UserProfileDelegate {
    
    // MARK: - Properties
    var profileViewController: UserProfileViewController!
    var passwordManager: PasswordManager!
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // name is explicite enough
        passwordManager = PasswordManager.shared
        
        // the view to display
        self.profileViewController = UserProfileViewController(nibName: "UserProfileViewController", bundle: nil)
        // add ourself as delegate
        self.profileViewController.delegate = self
        // set edit mode
        self.profileViewController.editionMode = true
        
        setupUI()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        
        // navigation bar
        self.navigationItem.title = "Edit profile"
        
        // pushing view under nav bar layout
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
        self.addChildViewController(self.profileViewController)
        self.view.addSubview(self.profileViewController.view)
        self.profileViewController.didMove(toParentViewController: self)
        
    }
    
    // MARK: - UserProfileDelegate
    
    func validate(user: UserProfil) {
        
        SwiftSpinner.show("Updating..")
        
        // get the current user
        let realm = try! Realm()
        let currentUser = realm.objects(User.self).filter("isCurrent == true").first!
        
        // get supposed password
        let tryPassword = user.oldPassword!
        
        // get valid value
        let currentPassword = currentUser.password
        let currentSalt = currentUser.salt
        
        // compute password in background
        // because password hashing may be heavy operation
        DispatchQueue.global(qos: .background).async {
            
            // try to verify
            let passwordIsValid = self.passwordManager.verifyPassword(tryPassword: tryPassword, salt: currentSalt, correctPassword: currentPassword)
            
            // verification succeed
            if let passwordIsValid = passwordIsValid, passwordIsValid {
                
                var newPasswordCrypted: String?
                var newSalt: String?
                
                // is there a new password?
                if let newPassword = user.password {
                    
                    // try to create the hash
                    let saltAndPassword = self.passwordManager.createHash(password: newPassword)
                
                    newPasswordCrypted = saltAndPassword?.passwordHashed
                    newSalt = saltAndPassword?.salt
                    
                }
                
                // then UI
                DispatchQueue.main.async {
                    
                    // update
                    let realm = try! Realm()
                    try! realm.write {
                        currentUser.email = user.email
                        currentUser.firstName = user.firstName
                        currentUser.lastName = user.lastName
                        currentUser.birth = user.birthday
                        currentUser.gender = user.gender
                        currentUser.weight = user.weight
                        currentUser.weight = user.weight
                        
                        // update password
                        if let newPassword = newPasswordCrypted, let newSalt = newSalt {
                            currentUser.password = newPassword
                            currentUser.salt = newSalt
                        }
                    }
                    
                    SwiftSpinner.show("Profil\nupdated", animated: false)
                    
                    // after a second hide spinner
                    // and display the settings controller
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        SwiftSpinner.hide({
                            // back to settings
                            self.navigationController?.popViewController(animated: true)
                        })
                    })
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

//
//  RegisterViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 02/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import RealmSwift
import SwiftSpinner

import UIKit

class RegisterViewController: UIViewController, UserProfileDelegate {
    
    // MARK: - Properties
    var profileViewController: UserProfileViewController!
    var passwordManager: PasswordManager!
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // name is explicite enough
        passwordManager = PasswordManager.shared
        
        setupUI()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        
        // navigation bar
        self.navigationItem.title = "Register"
        
        // pushing view under nav bar layout
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
        // the view to display
        self.profileViewController = UserProfileViewController(nibName: "UserProfileViewController", bundle: nil)
        self.addChildViewController(self.profileViewController)
        self.view.addSubview(self.profileViewController.view)
        self.profileViewController.didMove(toParentViewController: self)
        
        // add ourself as delegate
        self.profileViewController.delegate = self
        
    }
    
    // MARK: - UserProfileDelegate

    func validate(user: UserProfil) {
        
        SwiftSpinner.show("Registration")
        
        // in background we add the user to the database
        // because password hashing and write to DB may be heavy operation
        DispatchQueue.global(qos: .background).async {
            
            // try to create the hash
            let saltAndPassword = self.passwordManager.createHash(password: user.password)
            
            // creation succeed
            if let saltAndPassword = saltAndPassword {
                
                let passwordCrypted: String = saltAndPassword.passwordHashed
                let salt: String = saltAndPassword.salt
                
                // create the user
                let userToRegister = User(email: user.email,
                                          password: passwordCrypted,
                                          salt: salt,
                                          firstName: user.firstName,
                                          lastName: user.lastName,
                                          birth: user.birthday,
                                          gender: user.gender,
                                          weight: user.weight,
                                          size: user.size
                                    )
                
                // add to the DB
                // and set as current user
                let realm = try! Realm()
                try! realm.write {
                    realm.add(userToRegister)
                    userToRegister.setAsCurrent()
                }

                // dismiss view
                DispatchQueue.main.async {
                    
                    // add view with dismissal after a sec
                    SwiftSpinner.show(duration: 1, title: "Registration\ncomplete", animated: false)
                    
                    // remove view, registration is done
                    //self.dismiss(animated: true, completion: nil)
                    self.displayMain()
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                    // add view with dismissal after a sec
                    SwiftSpinner.show(duration: 1, title: "Error", animated: false)
                }
                
            }

        
        }
        
    }

}

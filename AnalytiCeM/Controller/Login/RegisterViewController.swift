//
//  RegisterViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 02/05/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import CryptoSwift
import RealmSwift

import UIKit

class RegisterViewController: UIViewController, UserProfileDelegate {
    
    // MARK: - Properties
    var profileViewController: UserProfileViewController!
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // in background we add the user to the database
        // because password hashing and write to DB may be heavy operation
        DispatchQueue.global(qos: .background).async {
        
            var passwordCrypted: String?
            var salted: String?
            
            // password crypt
            do {
                
                let password: Array<UInt8> = Array(user.password.utf8)
                // generated unique salt
                let salt: Array<UInt8> = Array(UUID().uuidString.utf8)
                
                let passwordValue = try PKCS5.PBKDF2(password: password, salt: salt, iterations: 4096, variant: .sha512).calculate()
                
                // export has readable string
                passwordCrypted = passwordValue.toHexString()
                salted = salt.toHexString()
                
            } catch let error {
                print(error)
                fatalError()
            }
            
            // create the user
            let userToRegister = User(email: user.email,
                                      password: passwordCrypted!,
                                      salt: salted!,
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
        
        }
        
        
        // remove view, registration is done
        self.dismiss(animated: true, completion: nil)
    }

}

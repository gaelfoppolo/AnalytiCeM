//
//  RegisterViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 02/05/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//


import Eureka
import RealmSwift

import UIKit

class RegisterViewController: UserProfileViewController {
    
    // MARK: - Properties
    
    let realm = try! Realm()
    var users: Results<User>!
    
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
        
    }

    // MARK: - IBAction

    // MARK: - Logic

    override func validate() {
        
        // retrieve values
        let email = (form.rowBy(tag: kSectionAccountTagEmail) as! EmailRow).value!
        let password = (form.rowBy(tag: kSectionAccountTagPassword) as! PasswordRow).value!
        let firstName = (form.rowBy(tag: kSectionUserTagLastName) as! TextRow).value!
        let lastName = (form.rowBy(tag: kSectionUserTagLastName) as! TextRow).value!
        let birthday = (form.rowBy(tag: kSectionUserTagBirthday) as! DateRow).value!
        let gender = (form.rowBy(tag: kSectionUserTagGender) as! SegmentedRow<String>).value!
        let weight = (form.rowBy(tag: kSectionUserTagWeight) as! PickerInlineRow<Int>).value!
        let size = (form.rowBy(tag: kSectionUserTagSize) as! PickerInlineRow<Int>).value!
        
        // todo:
        // password crypt
        // add to Realm
        
        // dismiss view
        self.dismiss(animated: true, completion: nil)
    }

}

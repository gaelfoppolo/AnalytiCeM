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

class RegisterViewController: FormViewController {
    
    // MARK: - Properties
    
    let realm = try! Realm()
    var users: Results<User>!
    
    let kSectionTagRegister = "register"
    let kSectionTagValidate = "validateRegister"
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        
        // navigation bar
        self.navigationItem.title = "Register"
        
        //
        
    }

    // MARK: - IBAction

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

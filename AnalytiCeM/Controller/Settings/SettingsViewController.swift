//
//  SettingsViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 16/04/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Constant
    
    let kCellIdentifier = "cellDevice"
    
    // Section 1: User
    let kSectionUser = 0
    let kNumberOfRowUser = 1
    let kRowUser = 0
    let kTitleUser = "User"
    
    // Section 2: Device
    let kSectionDevice = 1
    let kNumberOfRowDevice = 1
    let kRowDevice = 0
    let kTitleDevice = "Device"
    
    // MARK: - IBOutlet
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Settings"
        
        // being the delegate and the data source of the tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // record cell in the tableView
        self.tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: kCellIdentifier)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if (section == kSectionUser) {
            return kTitleUser
        }
        else if (section == kSectionDevice) {
            return kTitleDevice
        }
        else {
            return "todo"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == kSectionUser) {
            return kNumberOfRowUser
        }
        else if (section == kSectionDevice) {
            return kNumberOfRowDevice
        }
        else {
            return 0
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // recover the cell
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath)
        
        var imageName: String?

        // config the cell, according to section
        if (indexPath.section == kSectionUser) {
            if (indexPath.row == kRowUser) {
                cell.textLabel?.text = kTitleUser
                imageName = "settings-row-user"
            }
        } else if (indexPath.section == kSectionDevice) {
            if (indexPath.row == kRowDevice) {
                cell.textLabel?.text = kTitleDevice
                imageName = "settings-row-device"
            }
        }
        
        // add the image rounded
        let image = UIImage(named: imageName!)
        cell.imageView?.image = image
        cell.imageView?.layer.cornerRadius = (image?.size.width)!/2
        cell.imageView?.layer.masksToBounds = true
            
        // cell is configured
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var viewController: UIViewController?
        
        // select the view do display
        if (indexPath.section == kSectionUser) {
            viewController = UserViewController(nibName: "UserViewController", bundle: nil)
        } else if (indexPath.section == kSectionDevice) {
            viewController = DeviceViewController(nibName: "DeviceViewController", bundle: nil)
        }
        
        // display the view
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }

}

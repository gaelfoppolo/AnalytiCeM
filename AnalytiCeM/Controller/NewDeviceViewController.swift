//
//  NewDeviceViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 30/04/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import Eureka
import RealmSwift

import CoreBluetooth
import UIKit

class NewDeviceViewController: FormViewController, ChooseMuseDelegate {
    
    // MARK: - Properties
    
    let realm = try! Realm()
    var muses: Results<Muse>!
    var btManager: BluetoothStatusManager!
    
    // MARK: View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // retrieve the list of Muse
        muses = realm.objects(Muse.self)
        
        try! realm.write {
            /*realm.delete(muses)
            for _ in 0..<3 {
                realm.add(Muse(name: UUID().uuidString))
            }
            muses.last?.setAsCurrent(true)*/
        }
        
        // name is explicite enough
        btManager = BluetoothStatusManager.shared
        
        setupUI()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // subscribe
        registerBluetoothStatusChange(handler: handleBluetoothChange)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // unsubscribe
        unregisterBluetoothStatusChange()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        
        // navigation bar
        self.navigationItem.title = "Device"
        
        // button Add on the right
        let rightButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(NewDeviceViewController.addAction(_:))
        )
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        // disabled until Bluetooh status is checked
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        // create the section with proper setup
        let deviceSection = SelectableSection<ListCheckRow<String>>(
            "Your devices",
            selectionType: .singleSelection(enableDeselection: false)
        )
        
        // add the section to the form
        form.append(deviceSection)

        // populate the section with the Muses
        for muse in muses {
            // retrieve the name & status
            let museName = muse.getName()
            let museStatus = muse.getStatus()
            // create the row
            let row = ListCheckRow<String>(museName) { listRow in
                listRow.title = museName
                listRow.selectableValue = museName
                listRow.value = nil
            }
            // append the row to the section
            deviceSection.append(row)
            
            // should select?
            if museStatus {
                row.didSelect()
            }

        }

    }
    
    // MARK: - IBAction
    
    func addAction(_ sender: UIButton) {
        
        // the view to display
        let lPopupVC = AddMuseViewController(nibName: "AddMuseViewController", bundle: nil)
        
        // no background
        lPopupVC.view.backgroundColor = UIColor.clear
        
        // on top of the parent view
        lPopupVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        lPopupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        // register as delegate
        lPopupVC.delegate = self
        
        // display
        self.present(lPopupVC, animated: true, completion: nil)
        
    }
    
    // MARK: - Eureka
    
    override func valueHasBeenChanged(for row: BaseRow, oldValue: Any?, newValue: Any?) {
    
        if row.section === form[0] {
            let selectedRow = (row.section as! SelectableSection<ListCheckRow<String>>).selectedRow()
            if let value = selectedRow?.baseValue {
                // todo
                // update Realm
            }
        }
    
    }
    
    // MARK: - ChooseMuseDelegate
    
    func didChoose(muse: IXNMuse) {
        
        // to DB
        // add if not exist
        
        //muse.getName()
        //try! realm.write {
            //lMuse.setValue(museName, forKeyPath: "name")
        //}
        
        // then add to tableView, reload
        //saveCurrent(muse: muse)
    
    }
    
    // MARK: - Logic
    
    func handleBluetoothChange(notification : Notification) {
        let status = notification.object as! CBManagerState
        
        // activate button only if Bluetooth is available
        self.navigationItem.rightBarButtonItem?.isEnabled = (status == .poweredOn)
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

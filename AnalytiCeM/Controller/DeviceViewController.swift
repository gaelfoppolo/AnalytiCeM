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

class DeviceViewController: FormViewController, ChooseMuseDelegate {
    
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
            realm.delete(muses)
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
    
    override func viewDidAppear(_ animated: Bool) {
        /*try! realm.write {
            //realm.delete(muses)
            for _ in 0..<3 {
                realm.add(Muse(name: UUID().uuidString))
            }
            muses.last?.setAsCurrent(true)
        }*/
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
            action: #selector(DeviceViewController.addAction(_:))
        )
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        // check Bluetooh status
        self.navigationItem.rightBarButtonItem?.isEnabled = (btManager.currentStatus == .poweredOn)
        
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
                // update Realm
                let muse = muses.filter("name == %@", value)
                try! realm.write {
                    muse.first?.setAsCurrent(true)
                }
            }
        }
    
    }
    
    // MARK: - ChooseMuseDelegate
    
    func didChoose(muse: IXNMuse) {
        
        // get the name
        let museName = muse.getName()
        
        // check if already added
        let alreadyExist = muses.filter("name == %@", museName)
        if alreadyExist.count != 0 {
            return
        }
        
        // add it to Realm
        try! realm.write {
            realm.add(Muse(name: museName))
        }
        
        // create the row
        let newRow = ListCheckRow<String>(museName){ listRow in
                listRow.title = museName
                listRow.selectableValue = museName
                listRow.value = nil
        }
        
        // select the row
        newRow.didSelect()
        
        // append the row to the section and reload the table
        form.last?.append(newRow)
        form.last?.reload()
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

//
//  PagingMenuViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 23/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

import PagingMenuController
import RealmSwift

class PagingMenuViewController: UIViewController {
    
    // MARK: Properties
    
    var datas: Results<Data>!
    
    // MARK: View

    override func viewDidLoad() {
        super.viewDidLoad()

        let options = PagingMenuOptions(datas: datas)
        
        let pagingMenuController = PagingMenuController(options: options)        
        addChildViewController(pagingMenuController)
        view.layout(child: pagingMenuController.view)
        view.addSubview(pagingMenuController.view)
        pagingMenuController.didMove(toParentViewController: self)
    }


}

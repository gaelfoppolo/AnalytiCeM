//
//  NewSessionViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 13/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

import Spring

class NewSessionViewController: UIViewController, ActivityParameterDelegate {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var viewPopup: SpringView!
    
    var delegate: ActivityParameterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // opening
        self.viewPopup.animation = "zoomIn"
        self.viewPopup.duration	= 0.5
        self.viewPopup.animate()
        
    }
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // closing
        self.viewPopup.animation = "zoomOut"
        self.viewPopup.duration	= 0.5
        self.viewPopup.animate()
        
    }
    
    private func setupUI() {
        
        // session parameters controller
        let sessionParametersViewController = SessionParametersViewController(nibName: "SessionParametersViewController", bundle: nil)
        
        // the nav controller
        let sessionController = UINavigationController(rootViewController: sessionParametersViewController)
        
        // navigation bar
        sessionParametersViewController.navigationItem.title = "New session"
        
        // button exit on the right
        let logoutButtonItem = UIBarButtonItem(title: "Cancel",
                                               style: .plain,
                                               target: self,
                                               action: #selector(actionClose)
        )
        sessionParametersViewController.navigationItem.rightBarButtonItem = logoutButtonItem
        
        // add it to the view
        self.addChildViewController(sessionController)
        self.viewPopup.layout(child: sessionController.view)
        self.viewPopup.addSubview(sessionController.view)
        sessionController.didMove(toParentViewController: self)
        
        // add ourself as delegate
        sessionParametersViewController.delegate = self
        
    }
    
   func actionClose() {
        // close popup
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - ActivityParameterDelegate
    
    func didChoose(parameters activity: Activity) {
        // if delegate
        if (self.delegate != nil) {
            
            // call delegate
            self.delegate!.didChoose(parameters: activity)
            self.dismiss(animated: true, completion: nil)
        }
    }

}

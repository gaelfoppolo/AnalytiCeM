//
//  NewSessionViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 13/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

import Spring

class NewSessionViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var viewPopup: SpringView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                                               action: #selector(actionClose(_:))
        )
        sessionParametersViewController.navigationItem.rightBarButtonItem = logoutButtonItem
        
        // add it to the view
        self.addChildViewController(sessionController)
        self.viewPopup.layout(child: sessionController.view)
        self.viewPopup.addSubview(sessionController.view)
        sessionController.didMove(toParentViewController: self)

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
    
    // MARK: - IBAction
    
    @IBAction func actionClose(_ sender: Any) {
        // close popup
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func actionStart(_ sender: Any) {
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

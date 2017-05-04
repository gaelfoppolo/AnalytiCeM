//
//  AppDelegate.swift
//  AnalytiCeM
//
//  Created by Gaël on 11/04/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import UIKit

import ESTabBarController_swift
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // realm, delete the data if the DB scheme changed
        // prevent crashes, remove when go prod
        let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = config
        
        // create the frame
        window = UIWindow(frame: UIScreen.main.bounds)

        // our tab bar controller
        let tabBarController = ESTabBarController()
        // color of the bar, same as cell background
        tabBarController.tabBar.barTintColor = UIColor.init(red: 23/255.0, green: 149/255.0, blue: 158/255.0, alpha: 1.0)
        
        // session controller
        let tabViewControllerSession = ActivityViewController(
            nibName:"ActivityViewController",
            bundle: nil)
        let navSessionController = UINavigationController(rootViewController: tabViewControllerSession)
        
        // main controller
        let tabViewControllerMain = MainViewController(
            nibName: "MainViewController",
            bundle: nil)
        let navMainController = UINavigationController(rootViewController: tabViewControllerMain)

        // settings controller
        let tabViewControllerSettings = SettingsViewController(
            nibName:"SettingsViewController",
            bundle: nil)
        let navSettingsController = UINavigationController(rootViewController: tabViewControllerSettings)
        
        // init with view, title, image and image when selected
        navSessionController.tabBarItem = ESTabBarItem.init(BounceContentView(),
                                                            title: "Session",
                                                            image: UIImage(named: "ti-session"),
                                                            selectedImage: UIImage(named: "ti-session-selected")
        )
        navMainController.tabBarItem = ESTabBarItem.init(BigContentView(),
                                                         title: nil,
                                                         image: UIImage(named: "ti-brain"),
                                                         selectedImage: UIImage(named: "ti-brain-selected")
        )
        navSettingsController.tabBarItem = ESTabBarItem.init(BounceContentView(),
                                                             title: "Settings",
                                                             image: UIImage(named: "ti-settings"),
                                                             selectedImage: UIImage(named: "ti-settings-selected")
        )
        
        let controllers = [navSessionController, navMainController, navSettingsController]
        
        // set the navbar to opaque to all navigation bar
        controllers.forEach({controller in
            controller.navigationBar.isTranslucent = false
            //controller.navigationBar.barTintColor = UIColor.init(red: 23/255.0, green: 149/255.0, blue: 158/255.0, alpha: 1.0)
        })
        
        // add the controllers to the tab bar
        tabBarController.viewControllers = controllers
        
        // select the main view by default
        tabBarController.selectedIndex = 1
        
        // add the tab bar to our window
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        // login
        let realm = try! Realm()
        let currentUser = realm.objects(User.self).filter("isCurrent == true").first
        if currentUser == nil {
            // no current user, display login
            
            // login controller
            let lLoginVC = LoginViewController(
                nibName: "LoginViewController",
                bundle: nil)
            
            // login navigation controller
            let navLoginController = UINavigationController(rootViewController: lLoginVC)
            
            // on top of the parent view
            navLoginController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            
            // and nice transition style
            navLoginController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            
            // display the login navigation controller
            window?.rootViewController?.present(navLoginController, animated: true, completion: nil)
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}


//
//  AppDelegate.swift
//  AnalytiCeM
//
//  Created by Gaël on 11/04/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import UIKit
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
        let tabBarController = UITabBarController()
        
        // main controller
        let tabViewControllerMain = MainViewController(
            nibName: "MainViewController",
            bundle: nil)
        let navMainController = UINavigationController(rootViewController: tabViewControllerMain)
        
        // activity controller
        let tabViewControllerActivity = ActivityViewController(
            nibName:"ActivityViewController",
            bundle: nil)
        let navActivityController = UINavigationController(rootViewController: tabViewControllerActivity)

        // settings controller
        let tabViewControllerSettings = SettingsViewController(
            nibName:"SettingsViewController",
            bundle: nil)
        let navSettingsController = UINavigationController(rootViewController: tabViewControllerSettings)
        
        // add title and image
        navMainController.tabBarItem = UITabBarItem(title: "Main", image: nil, tag: 1)
        navActivityController.tabBarItem = UITabBarItem(title: "Activity", image: nil, tag: 2)
        navSettingsController.tabBarItem = UITabBarItem(title: "Settings", image: nil, tag: 3)
        
        // add the controllers to the tab bar
        let controllers = [navMainController, navActivityController, navSettingsController]
        
        // set the navbar to opaque to all navigation bar
        controllers.forEach({controller in
            controller.navigationBar.isTranslucent = false
        })
        
        tabBarController.viewControllers = controllers
        
        // add the tab bar to our window
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
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


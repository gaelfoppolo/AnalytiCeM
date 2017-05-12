//
//  AppDelegate.swift
//  AnalytiCeM
//
//  Created by Gaël on 11/04/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

import ESTabBarController_swift
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var tabBarController: ESTabBarController?
    var navLoginController: UINavigationController?
    
    var btManager: BluetoothStatusManager!
    var connectivityManager: ConnectivityManager!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // realm, delete the data if the DB scheme changed
        // prevent crashes, remove when go prod
        //let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        //Realm.Configuration.defaultConfiguration = config
        
        // fill database
        FillRealm.defaults()
        
        // theme of the app
        Theme.default.apply()
        
        // create the frame
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // manager of Bluetooth status
        btManager = BluetoothStatusManager.shared
        
        // manager of Internet status
        connectivityManager = ConnectivityManager.shared
        
        // apply theme
        Theme.current.apply()
        
        // our tab bar controller
        tabBarController = ESTabBarController()
        tabBarController?.tabBar.isTranslucent = false
        
        // session controller
        let tabViewControllerSession = SessionViewController(
            nibName:"SessionViewController",
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
        })
        
        // add the controllers to the tab bar
        tabBarController?.viewControllers = controllers
        
        // select the main view by default
        tabBarController?.selectedIndex = 1
        
        // login controller
        let lLoginVC = LoginViewController(
            nibName: "LoginViewController",
            bundle: nil)
        
        // login navigation controller
        navLoginController = UINavigationController(rootViewController: lLoginVC)
        
        // on top of the parent view
        navLoginController?.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        // and nice transition style
        navLoginController?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        // retrieve current user
        let realm = try! Realm()
        let currentUser = realm.objects(User.self).filter("isCurrent == true").first
        
        // no current user, display login
        if currentUser == nil {
            
            // display the login navigation controller
            displayLogin()
            
        } else {
            
            // directly display tab bar
            displayMain()
            
        }
        
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
    
    // MARK: - Custom
    
    func displayLogin() {
        
        window?.rootViewController = navLoginController
    }
    
    func displayMain() {
        
        window?.rootViewController = tabBarController
        
    }

}


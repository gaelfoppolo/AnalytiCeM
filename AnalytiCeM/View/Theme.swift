//
//  Theme.swift
//  AnalytiCeM
//
//  Created by Gaël on 06/05/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import UIKit
import Eureka

enum Theme: Int {
    
    // MARK: - Properties
    
    // theme available
    case `default`, dark
    
    // access the selected theme within the enum
    private enum Keys {
        static let selectedTheme = "selectedTheme"
    }
    
    // retrieve the current theme, default by default ;p
    static var current: Theme {
        let storedTheme = UserDefaults.standard.integer(forKey: Keys.selectedTheme)
        return Theme(rawValue: storedTheme) ?? .default
    }
    
    // the main color of the selected theme
    var mainColor: UIColor {
        switch self {
            case .default:
                // blue-green
                return UIColor(red: 23/255.0, green: 149/255.0, blue: 158/255.0, alpha: 1.0)
            case .dark:
                return UIColor(red: 39.0/255.0, green: 45.0/255.0, blue: 29.0/255.0, alpha: 1.0)
        }
    }
    
    // the text color of the selected theme
    var textColor: UIColor {
        switch self {
        case .default:
            return UIColor.white
        case .dark:
            return UIColor.white
        }
    }
    
    // the style of the bar
    var barStyle: UIBarStyle {
        switch self {
        case .default:
            return .default
        case .dark:
            return .black
        }
    }
    
    var statusBar: UIStatusBarStyle {
        switch self {
        case .default:
            return .lightContent
        case .dark:
            return .lightContent
        }
    }
    
    // MARK: - Logic
    
    func apply() {
        // save theme
        UserDefaults.standard.set(rawValue, forKey: Keys.selectedTheme)
        UserDefaults.standard.synchronize()
        
        // status bar
        UIApplication.shared.statusBarStyle = statusBar
        
        // apply color to the application's window
        UIApplication.shared.delegate?.window??.tintColor = mainColor
        
        // the color the navigation bar
        UINavigationBar.appearance().barTintColor = mainColor
        UINavigationBar.appearance().tintColor = textColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: textColor]
        
        // table view
        UITableViewCell.appearance().backgroundColor = textColor
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = mainColor
        
        // tab bar
        UITabBar.appearance().barTintColor = mainColor
        UITabBar.appearance().tintColor = textColor
        
    }
}

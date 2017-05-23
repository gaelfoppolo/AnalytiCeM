//
//  PagingMenuOptions.swift
//  AnalytiCeM
//
//  Created by Gaël on 23/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import Foundation
import PagingMenuController

struct PagingMenuOptions: PagingMenuControllerCustomizable {
    
    var componentType: ComponentType {
        return .all(menuOptions: MenuOptions(), pagingControllers: pagingControllers)
    }
    
    var pagingControllers: [UIViewController] {
        return [EEGChartViewController(), EEGChartViewController(), EEGChartViewController(), EEGChartViewController(), EEGChartViewController()]
    }
    
    struct MenuOptions: MenuViewCustomizable {
        var displayMode: MenuDisplayMode {
            return .infinite(widthMode: .fixed(width: 80), scrollingMode: .scrollEnabled)
        }
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItem1(), MenuItem2(), MenuItem3(), MenuItem4(), MenuItem5()]
        }
        var focusMode: MenuFocusMode {
            return .underline(height: 3, color: Theme.current.mainColor, horizontalPadding: 0, verticalPadding: 0)
        }
    }
    
    struct MenuItem1: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "First Menu"))
        }
    }
    struct MenuItem2: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "Second Menu"))
        }
    }
    struct MenuItem3: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "3 Menu"))
        }
    }
    struct MenuItem4: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "4 Menu"))
        }
    }
    struct MenuItem5: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "5 Menu"))
        }
    }
}

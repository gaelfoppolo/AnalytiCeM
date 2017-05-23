//
//  PagingMenuOptions.swift
//  AnalytiCeM
//
//  Created by Gaël on 23/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import Foundation

import PagingMenuController
import RealmSwift

struct PagingMenuOptions: PagingMenuControllerCustomizable {
    
    var datas: Results<Data>!
    
    init(datas: Results<Data>) {
        self.datas = datas
    }
    
    var componentType: ComponentType {
        return .all(menuOptions: MenuOptions(), pagingControllers: pagingControllers)
    }
    
    var pagingControllers: [UIViewController] {
        
        let eeg = EEGChartViewController()
        eeg.color = .black
        eeg.data = datas.map({ $0.eeg })
        
        let alpha = EEGChartViewController()
        alpha.color = .green
        alpha.data = datas.map({ $0.alpha })
        
        let beta = EEGChartViewController()
        beta.color = .orange
        beta.data = datas.map({ $0.beta })
        
        let delta = EEGChartViewController()
        delta.color = .blue
        delta.data = datas.map({ $0.delta })
        
        let gamma = EEGChartViewController()
        gamma.color = .red
        gamma.data = datas.map({ $0.gamma })
        
        let theta = EEGChartViewController()
        theta.color = .purple
        theta.data = datas.map({ $0.theta })
        
        return [eeg, alpha, beta, delta, gamma, theta]
    }
    
    struct MenuOptions: MenuViewCustomizable {
        var displayMode: MenuDisplayMode {
            return .infinite(widthMode: .fixed(width: 80), scrollingMode: .scrollEnabled)
        }
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuEEG(), MenuAlpha(), MenuBeta(), MenuDelta(), MenuGamma(), MenuTheta()]
        }
        var focusMode: MenuFocusMode {
            return .underline(height: 3, color: Theme.current.mainColor, horizontalPadding: 0, verticalPadding: 0)
        }
    }
    
    struct MenuEEG: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "EEG"))
        }
    }
    struct MenuAlpha: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "Relax"))
        }
    }
    struct MenuBeta: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "Casual"))
        }
    }
    struct MenuDelta: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "Sleep"))
        }
    }
    struct MenuGamma: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "Thinking"))
        }
    }
    struct MenuTheta: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "Relax++"))
        }
    }
}

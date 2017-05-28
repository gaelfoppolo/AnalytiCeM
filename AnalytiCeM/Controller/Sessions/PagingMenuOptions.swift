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
        
        let pie = SynthesisChartViewController()
        pie.colors = [UIColor]()
        
        let eeg = EEGChartViewController()
        eeg.color = .black
        eeg.data = datas.map({ $0.eeg })
        
        let alpha = EEGChartViewController()
        alpha.color = .green
        alpha.data = datas.map({ $0.alpha })
        
        pie.colors.append(alpha.color)
        pie.alpha = alpha.data
        
        let beta = EEGChartViewController()
        beta.color = .orange
        beta.data = datas.map({ $0.beta })
        
        pie.colors.append(beta.color)
        pie.beta = beta.data
        
        let delta = EEGChartViewController()
        delta.color = .blue
        delta.data = datas.map({ $0.delta })
        
        pie.colors.append(delta.color)
        pie.delta = delta.data
        
        let gamma = EEGChartViewController()
        gamma.color = .red
        gamma.data = datas.map({ $0.gamma })
        
        pie.colors.append(gamma.color)
        pie.gamma = gamma.data
        
        let theta = EEGChartViewController()
        theta.color = .purple
        theta.data = datas.map({ $0.theta })
        
        pie.colors.append(theta.color)
        pie.theta = theta.data

        let jaw = CountChartViewController()
        jaw.color = .gray
        jaw.data = datas.map({ Double($0.jawCount) })
        
        let blink = CountChartViewController()
        blink.color = .brown
        blink.data = datas.map({ Double($0.blinkCount) })
        
        return [eeg, alpha, beta, delta, gamma, theta, jaw, blink, pie]
    }
    
    struct MenuOptions: MenuViewCustomizable {
        var displayMode: MenuDisplayMode {
            return .infinite(widthMode: .fixed(width: 80), scrollingMode: .scrollEnabled)
        }
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuEEG(), MenuAlpha(), MenuBeta(), MenuDelta(), MenuGamma(), MenuTheta(), MenuJaw(), MenuBlink(), MenuPie()]
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
    struct MenuJaw: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "Jaw"))
        }
    }
    struct MenuBlink: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "Blink"))
        }
    }
    struct MenuPie: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "Synthesis"))
        }
    }
}

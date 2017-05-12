//
//  StartStopSessionUIButton.swift
//  AnalytiCeM
//
//  Created by Gaël on 12/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

public enum SessionStatus: Int {
    case start, stop
}

class StartStopSessionUIButton: UIButton {

    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Private Helper Methods
    
    // Performs the initial setup.
    private func setupView() {
        
        // corner
        self.layer.cornerRadius = 5
        // border
        self.layer.borderColor = Theme.current.mainColor.cgColor
        self.layer.borderWidth = 1
        // title color
        self.setTitleColor(Theme.current.mainColor, for: .normal)
        
        // title adaptative
        self.titleLabel?.numberOfLines = 1
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.lineBreakMode = .byClipping
        
    }
    
    public func update(to state: SessionStatus, controller: UIViewController) {
        
        // the attributes of the button to be set
        var button: (title: String, image: String, action: Selector)
        
        switch state {
        case .start:
            button.title = "Start a new session"
            button.image = "session-start"
            button.action = #selector(MainViewController.launchSession)
            break
        case .stop:
            button.title = "Stop current session"
            button.image = "session-stop"
            button.action = #selector(MainViewController.stopSession)
            break
        }
        
        self.setImage(UIImage(named: button.image), for: .normal)
        self.setTitle(button.title, for: .normal)
        
        self.removeTarget(nil, action: nil, for: .allEvents)
        self.addTarget(controller, action: button.action, for: .touchUpInside)
    }

}

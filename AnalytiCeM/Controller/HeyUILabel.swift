//
//  HeyUILabel.swift
//  AnalytiCeM
//
//  Created by Gaël on 12/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

class HeyUILabel: UILabel {
    
    private let dateFormatter = DateComponentsFormatter()

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
        
        // formatter
        dateFormatter.allowedUnits = [.day, .hour, .minute, .second]
        dateFormatter.unitsStyle = .abbreviated
    
        self.text = ""
        
    }
    
    public func display(name: String) {
        
        self.text = "Hey \(name)"
        
    }
    
    public func display(time seconds: UInt) {
        
        self.text = dateFormatter.string(from: TimeInterval(seconds))!
        
    }

}

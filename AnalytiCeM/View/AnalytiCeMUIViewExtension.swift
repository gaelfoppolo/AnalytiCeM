//
//  AnalytiCeMUIViewExtension.swift
//  AnalytiCeM
//
//  Created by Gaël on 08/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

extension UIView {
    
    func enableConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func layout(child: UIView) {
        child.enableConstraints()
        addSubview(child)

        let topSideConstraint = NSLayoutConstraint(item: child, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let rightConstraint = NSLayoutConstraint(item: child, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: child, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let leftSideConstraint = NSLayoutConstraint(item: child, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0)
        
        //let widthConstraint = NSLayoutConstraint(item: child, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0.0)
        //let heightConstraint = NSLayoutConstraint(item: child, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0.0)
        
        self.addConstraints([topSideConstraint, rightConstraint, bottomConstraint, leftSideConstraint])
        self.layoutIfNeeded()
        
    }
    
    func layoutCenter(child: UIView) {
        child.enableConstraints()
        addSubview(child)
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: child.centerXAnchor),
            centerYAnchor.constraint(equalTo: child.centerYAnchor)
            ])
    }
    
    func cornerRoundedWithThinBorder() {
        
        // corner
        self.layer.cornerRadius = 5
        // border
        self.layer.borderColor = Theme.current.mainColor.cgColor
        self.layer.borderWidth = 1
        
    }
    
}

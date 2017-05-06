//
//  BigContentView.swift
//  AnalytiCeM
//
//  Created by Gaël on 05/05/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import UIKit

import pop

class BigContentView: BounceContentView {
    
    // MARK: - View

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView.backgroundColor = Theme.current.mainColor
        self.imageView.layer.borderWidth = 3.0
        self.imageView.layer.borderColor = Theme.current.textColor.cgColor
        self.imageView.layer.cornerRadius = 35
        self.insets = UIEdgeInsetsMake(-32, 0, 0, 0)
        let transform = CGAffineTransform.identity
        self.imageView.transform = transform
        self.superview?.bringSubview(toFront: self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let p = CGPoint.init(x: point.x - imageView.frame.origin.x, y: point.y - imageView.frame.origin.y)
        return sqrt(pow(imageView.bounds.size.width / 2.0 - p.x, 2) + pow(imageView.bounds.size.height / 2.0 - p.y, 2)) < imageView.bounds.size.width / 2.0
    }

}

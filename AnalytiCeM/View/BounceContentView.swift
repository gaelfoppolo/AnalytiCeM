//
//  BouncesContentView.swift
//  AnalytiCeM
//
//  Created by Gaël on 05/05/2017.
//  Copyright © 2017 Polyech. All rights reserved.
//

import UIKit

import ESTabBarController_swift

class BounceContentView: ESTabBarItemContentView {
    
    // MARK: - Properties

    public var duration = 0.3
    
    // MARK: - View

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // white text
        textColor = UIColor.white
        highlightTextColor = UIColor.white
        
        // white icon
        iconColor = UIColor.white
        highlightIconColor = UIColor.white
        
        // transparent background of item cell
        backdropColor = UIColor.clear
        highlightBackdropColor = UIColor.clear
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func selectAnimation(animated: Bool, completion: (() -> ())?) {
        self.bounceAnimation()
        completion?()
    }

    override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
        self.bounceAnimation()
        completion?()
    }
    
    // MARK: - Logic
    
    func bounceAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = kCAAnimationCubic
        imageView.layer.add(impliesAnimation, forKey: nil)
    }
}

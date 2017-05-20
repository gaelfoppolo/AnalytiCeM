//
//  WaveView.swift
//  AnalytiCeM
//
//  Created by Gaël on 15/04/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//
import UIKit
import QuartzCore

open class WaveView: UIView {
    
    open var points: [Double] = [] { didSet { setNeedsDisplay() } }
    
    fileprivate let wave = CAShapeLayer()
    
    fileprivate let labelMessage: UILabel = UILabel(frame: CGRect.zero)
    
    open override func awakeFromNib() {
        
        super.awakeFromNib()
        
        clipsToBounds = true

        tintColorDidChange()
        
        wave.fillColor = nil
        wave.lineWidth = 2.0
        
        layer.addSublayer(wave)
        
        // text
        labelMessage.text = "No Muse data"
        labelMessage.textColor = Theme.current.mainColor
        labelMessage.textAlignment = .center
        // adapt size
        labelMessage.adjustsFontSizeToFitWidth = true
        labelMessage.minimumScaleFactor = 0.5
        labelMessage.font = labelMessage.font.withSize(25)
        
        // constraints, center
        labelMessage.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelMessage)
        
        let xConstraint = NSLayoutConstraint(item: labelMessage,
                                             attribute: .centerX,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .centerX,
                                             multiplier: 1,
                                             constant: 0
        )
        
        let yConstraint = NSLayoutConstraint(item: labelMessage,
                                             attribute: .centerY,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .centerY,
                                             multiplier: 1,
                                             constant: 0
        )
        
        let widthConstraint = NSLayoutConstraint(item: labelMessage,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: self,
                                                 attribute: .width,
                                                 multiplier: 1,
                                                 constant: 0
        )
        
        let heightConstraint = NSLayoutConstraint(item: labelMessage,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .height,
                                                  multiplier: 1,
                                                  constant: 0
        )
        
        NSLayoutConstraint.activate([xConstraint, yConstraint, widthConstraint, heightConstraint])

    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        
        wave.strokeColor = self.tintColor.cgColor
    }
    
    open override func draw(_ rect: CGRect) {
        
        // build path
        let path: CGPath? = buildPath(points: points, inBounds: bounds)?.cgPath
        wave.path = path
        
        // display message
        self.labelMessage.isHidden = (path != nil)
        
        super.draw(rect)
    }
    
    open override func layoutSubviews() {
        
        wave.frame = bounds
        super.layoutSubviews()
    }
    
    private func buildPath(points: [Double], inBounds bounds: CGRect) -> UIBezierPath? {
        
        // at least two points
        guard points.count >= 2 else { return nil }
        
        // get max value
        guard let maxValue = points.max(), maxValue > 0 else { return nil }
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0.0, y: bounds.height))
        
        for (index, point) in points.enumerated() {
            
            // x position
            let xProgress = CGFloat(index) / CGFloat(points.count - 1)
            
            let normalizedValue = CGFloat(point) / CGFloat(maxValue)
            
            // add to the path
            path.addLine(to: CGPoint(x: xProgress * bounds.width,
                                     y: bounds.height * (1.0 - normalizedValue)))
        }
        
        return path
    }
}

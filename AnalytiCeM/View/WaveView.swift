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
    
    open override func awakeFromNib() {
        
        super.awakeFromNib()
        
        clipsToBounds = true

        tintColorDidChange()
        
        wave.fillColor = nil
        wave.lineWidth = 1.0
        
        layer.addSublayer(wave)
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        
        wave.strokeColor = self.tintColor.cgColor
    }
    
    open override func draw(_ rect: CGRect) {
        
        wave.path = buildPath(points: points, inBounds: bounds)?.cgPath
        super.draw(rect)
    }
    
    open override func layoutSubviews() {
        
        wave.frame = bounds
        super.layoutSubviews()
    }
    
    private func buildPath(points: [Double], inBounds bounds: CGRect) -> UIBezierPath? {
        
        // il y a au moins deux points
        guard points.count >= 2 else { return nil }
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0.0, y: bounds.height))
        
        for (index, point) in points.enumerated() {
            
            // position dans l'axe horizontal
            let xProgress = CGFloat(index) / CGFloat(points.count - 1)
            
            let normalizedValue = CGFloat(point)
            
            // ajout au chemin
            path.addLine(to: CGPoint(x: xProgress * bounds.width,
                                     y: bounds.height * (1.0 - normalizedValue)))
        }
        
        return path
    }
}

//
//  WeatherView.swift
//  AnalytiCeM
//
//  Created by Gaël on 10/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

class WeatherView: UIView {
    
    // MARK: - IBOutlet

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var conditions: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        let view = viewFromNibForClass()
        view.frame = bounds
        
        // Auto-layout stuff.
        view.autoresizingMask = [
            UIViewAutoresizing.flexibleWidth,
            UIViewAutoresizing.flexibleHeight
        ]
        
        setupUI()
        
        // Show the view.
        addSubview(view)
    }
    
    private func setupUI() {
        
        // corner
        self.layer.cornerRadius = 5
        // border
        self.layer.borderColor = Theme.current.mainColor.cgColor
        self.layer.borderWidth = 1
        
        // activity
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.color = Theme.current.mainColor
        
        // label
        self.conditions.text = "No info yet"
        self.temperature.text = ""
        
    }
    
    // Loads a XIB file into a view and returns this view.
    private func viewFromNibForClass() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
    
    // MARK: - Logic
    
    public func display(weather: Weather) {
        
        // temperature is not hidden
        self.temperature.isHidden = false
        
        self.icon.image = UIImage(named: weather.icon)
        self.conditions.text = weather.condition
        self.temperature.text = "\(weather.temperature)°C"
        
    }
    
    public func display(error: String) {
        
        // temperature is hidden
        self.temperature.isHidden = true
        
        self.conditions.text = error
        
    }

}

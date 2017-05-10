//
//  GPSView.swift
//  AnalytiCeM
//
//  Created by Gaël on 08/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import MapKit
import UIKit

class GPSView: UIView {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
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
        
        // disable user interaction
        self.mapView.isZoomEnabled = false
        self.mapView.isScrollEnabled = false
        self.mapView.isUserInteractionEnabled = false
        
        // activity
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.color = Theme.current.mainColor
        
        // label
        self.cityLabel.text = "No info yet"
        self.countryLabel.text = ""
        
    }
    
    // Loads a XIB file into a view and returns this view.
    private func viewFromNibForClass() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
    
    // MARK: - Logic
    
    public func changeZoomToCoordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    public func addMarker(placemark: CLPlacemark) {
        // remove annotations first
        self.mapView.removeAnnotations(self.mapView.annotations)
        // add marker then
        let mapPlacemark = MKPlacemark(placemark: placemark)
        self.mapView.addAnnotation(mapPlacemark)
    }
    
    public func display(city: String, country: String) {
        
        // country is not hidden
        self.countryLabel.isHidden = false
        
        self.cityLabel.text = city
        self.countryLabel.text = country
        
    }
    
    public func display(error: String) {
        
        // country is hidden
        self.countryLabel.isHidden = true
        
        self.cityLabel.text = error
        
    }

}

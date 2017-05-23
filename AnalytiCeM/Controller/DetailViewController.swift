//
//  DetailViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 21/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import MapKit
import UIKit

import RealmSwift

class DetailViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Properties
    
    var currentSession: Session!
    private let dateFormatter = DateFormatter()
    private let durationFormatter = DateComponentsFormatter()
    private let distanceFormatter = MKDistanceFormatter()
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var weatherView: WeatherView!
    @IBOutlet weak var activityTypes: UILabel!
    @IBOutlet weak var mentalState: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pagingMenu: UIView!
    
    // MARK: - UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // date formatter
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        // duration formatter
        durationFormatter.allowedUnits = [.day, .hour, .minute, .second]
        durationFormatter.unitsStyle = .abbreviated
        
        distanceFormatter.unitStyle = .abbreviated
        
        setupUI()
        
        fillView()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        self.dateLabel.cornerRoundedWithThinBorder()
        self.durationLabel.cornerRoundedWithThinBorder()
        self.weatherView.cornerRoundedWithThinBorder()
        self.activityTypes.cornerRoundedWithThinBorder()
        self.mentalState.cornerRoundedWithThinBorder()
        self.distance.cornerRoundedWithThinBorder()
        
        // the view to display
        let pageViewController = PagingMenuViewController()
        self.addChildViewController(pageViewController)
        self.pagingMenu.layout(child: pageViewController.view)
        self.pagingMenu.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        
    }
    
    private func fillView() {
        
        // title
        self.navigationItem.title = currentSession.activity?.label
        
        // date
        self.dateLabel.text = dateFormatter.string(from: currentSession.start as Date)
        
        // duration
        let duration = currentSession.end?.timeIntervalSince(currentSession.start as Date)
        self.durationLabel.text = durationFormatter.string(from: duration!)
        
        // weather
        self.weatherView.display(weather: currentSession.weather!)
        
        // activity types
        self.activityTypes.text = currentSession.activity?.types.map({ $0.label }).joined(separator: ", ")
        
        // mental state
        self.mentalState.text = currentSession.activity?.mentalState?.label
        
        // length
        self.distance.text = "Computing map.."
        
        // map
        self.mapView.showsCompass = true
        self.mapView.showsUserLocation = false
        self.mapView.showsBuildings = true
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        self.mapView.isPitchEnabled = true
        self.mapView.isRotateEnabled = true
        self.mapView.mapType = .standard
        self.mapView.delegate = self
        
        // pass the object across thread
        let sessionRef = ThreadSafeReference(to: currentSession)
        
        // do the heavy work in background
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                
                // try to resolve
                let realm = try! Realm()
                guard let session = realm.resolve(sessionRef) else {
                    return
                    // session was deleted
                }
                
                // retrieve coordinates
                let coordinates: [CLLocationCoordinate2D] = session.data.map { (data) -> CLLocationCoordinate2D in
                    return data.gps!.coordinate
                }
                
                // calc distance
                var distance: Double = 0
                var lastLoc: CLLocation?
                
                for coordinate in coordinates {
                    
                    // first pass
                    guard let last = lastLoc else {
                        lastLoc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        continue
                    }
                    
                    let current = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    let dist = last.distance(from: current)
                    distance += dist
                    
                    lastLoc = current
                    
                }
                
                // build polyline
                let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                
                // lat
                let lat: [CLLocationDegrees] = coordinates.map({ $0.latitude })
                let minLat: CLLocationDegrees? = lat.min()
                let maxLat: CLLocationDegrees? = lat.max()
                
                // lon
                let lon: [CLLocationDegrees] = coordinates.map({ $0.longitude })
                let minLon: CLLocationDegrees? = lon.min()
                let maxLon: CLLocationDegrees? = lon.max()
                
                // region
                var locationSpan = MKCoordinateSpan()
                locationSpan.latitudeDelta = maxLat! - minLat! + 0.001
                locationSpan.longitudeDelta = maxLon! - minLon! + 0.001
                
                var locationCenter = CLLocationCoordinate2D()
                locationCenter.latitude = (maxLat! + minLat!) / 2
                locationCenter.longitude = (maxLon! + minLon!) / 2
                
                let region = MKCoordinateRegionMake(locationCenter, locationSpan)
                
                // display
                DispatchQueue.main.async {
                    
                    self.mapView.setRegion(region, animated: true)
                    self.mapView.add(polyline)
                    self.distance.text = self.distanceFormatter.string(fromDistance: distance)
                }
                
            }
        }
        
    }
    
    // MARK: MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let lineRenderer = MKPolylineRenderer(overlay: overlay)
        lineRenderer.strokeColor = Theme.current.mainColor
        lineRenderer.lineWidth = 2
        return lineRenderer
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

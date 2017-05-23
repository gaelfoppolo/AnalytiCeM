//
//  DetailViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 21/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var currentSession: Session!
    private let dateFormatter = DateFormatter()
    private let durationFormatter = DateComponentsFormatter()
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var weatherView: WeatherView!
    @IBOutlet weak var activityTypes: UILabel!
    @IBOutlet weak var mentalState: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    // MARK: - UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // date formatter
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        // duration formatter
        durationFormatter.allowedUnits = [.day, .hour, .minute, .second]
        durationFormatter.unitsStyle = .abbreviated
        
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

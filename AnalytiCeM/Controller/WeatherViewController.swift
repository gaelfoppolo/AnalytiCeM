//
//  WeatherViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 07/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {
    
    // MARK: - Properties
    
    var weather: Weather? {
        didSet {
            updateUI()
        }
    }
    
    var error: String? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var condition: UILabel!
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        
        self.temperature.text = ""
        self.condition.text = ""
        
    }
    
    private func updateUI() {
        
        // weather is valid
        if let weather = weather {
            updateWeather(weather: weather)
        } else {
            displayError()
        }
        
    }
    
    private func updateWeather(weather: Weather) {
        
        self.icon.image = UIImage(named: weather.icon)
        self.temperature.text = "\(weather.temperature)°C"
        self.condition.text = weather.condition
        
        self.temperature.isHidden = false
        self.icon.isHidden = false
        
    }
    
    private func displayError() {
    
        self.condition.text = error ?? "Unknown error"
        self.temperature.isHidden = true
        self.icon.isHidden = true
    
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

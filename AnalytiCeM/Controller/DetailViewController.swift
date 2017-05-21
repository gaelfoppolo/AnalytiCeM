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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        
        // title
        
        self.navigationItem.title = currentSession.activity?.label
        
        // corner
        self.dateLabel.layer.cornerRadius = 5
        // border
        self.dateLabel.layer.borderColor = Theme.current.mainColor.cgColor
        self.dateLabel.layer.borderWidth = 1
        
        self.dateLabel.text = dateFormatter.string(from: currentSession.start as Date)
        
        // corner
        self.durationLabel.layer.cornerRadius = 5
        // border
        self.durationLabel.layer.borderColor = Theme.current.mainColor.cgColor
        self.durationLabel.layer.borderWidth = 1
        
        let duration = currentSession.end?.timeIntervalSince(currentSession.start as Date)
        
        self.durationLabel.text = durationFormatter.string(from: duration!)
        
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

//
//  CountChartViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 24/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

import Charts

class CountChartViewController: UIViewController {

    // MARK: - Properties
    
    var color: UIColor!
    var data: [Double]!
    
    // MARK: IBOutlets
    
    @IBOutlet weak var chart: BarChartView!
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chart.chartDescription?.enabled = false
        
        chart.dragEnabled = false
        chart.setScaleEnabled(false)
        chart.pinchZoomEnabled = false
        chart.drawGridBackgroundEnabled = false
        chart.maxHighlightDistance = 300.0
        
        chart.xAxis.enabled = false
        
        chart.rightAxis.enabled = false
        chart.legend.enabled = false
        
        setChart(dataPoints: data)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Logic
    
    func setChart(dataPoints: [Double]) {
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry.init(x: Double(i), y: dataPoints[i])
            dataEntries.append(dataEntry)
        }
        
        let set: BarChartDataSet = BarChartDataSet(values: dataEntries, label: "")
        
        set.setColor(color)
        set.drawValuesEnabled = false
        
        let data: BarChartData = BarChartData(dataSet: set)
        
        chart.data = data
        
    }

}

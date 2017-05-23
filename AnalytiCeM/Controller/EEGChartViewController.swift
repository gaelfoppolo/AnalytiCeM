//
//  EEGChartViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 23/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

import Charts

class EEGChartViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: IBOutlets

    @IBOutlet weak var chart: BarChartView!
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chart.chartDescription?.enabled = false
        
        chart.dragEnabled = true
        chart.setScaleEnabled(true)
        chart.pinchZoomEnabled = false
        chart.drawGridBackgroundEnabled = false
        chart.maxHighlightDistance = 300.0
        
        chart.xAxis.enabled = false
        
        chart.rightAxis.enabled = false
        chart.legend.enabled = false
        
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
        let unitsSold = [1.0, 4.0, 6.0, 3.0, 1.0, 6.0]
        
        setChart(dataPoints: months, values: unitsSold)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Logic
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry.init(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Units Sold")
        let chartData = BarChartData(dataSet: chartDataSet)
        chart.data = chartData
 
    }

}

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
    
    var color: UIColor!
    var data: [Double]!
    
    // MARK: IBOutlets

    @IBOutlet weak var chart: LineChartView!
    
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
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry.init(x: Double(i), y: dataPoints[i])
            dataEntries.append(dataEntry)
        }
        
        let set: LineChartDataSet = LineChartDataSet(values: dataEntries, label: "")
        
        set.mode = .horizontalBezier
        set.cubicIntensity = 0
        set.drawCirclesEnabled = false
        set.lineWidth = 0.5
        set.fillColor = color
        set.setColor(color)
        set.drawFilledEnabled = true
        set.drawValuesEnabled = false
        
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set)
        
        let data: LineChartData = LineChartData(dataSets: dataSets)
        
        chart.data = data
 
    }

}

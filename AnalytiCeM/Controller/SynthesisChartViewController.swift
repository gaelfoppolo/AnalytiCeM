//
//  SynthesisChartViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 24/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

import Charts

class SynthesisChartViewController: UIViewController {

    // MARK: - Properties
    
    var colors: [UIColor]!
    var alpha: [Double]!
    var beta: [Double]!
    var delta: [Double]!
    var gamma: [Double]!
    var theta: [Double]!
    
    // MARK: IBOutlets
    
    @IBOutlet weak var chart: PieChartView!
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chart.chartDescription?.enabled = false
        chart.maxHighlightDistance = 300.0
        
        chart.usePercentValuesEnabled = true
        chart.drawSlicesUnderHoleEnabled = false
        
        chart.legend.enabled = false
        
        let alphaSum = alpha.reduce(0.0, +)
        let betaSum = beta.reduce(0.0, +)
        let deltaSum = delta.reduce(0.0, +)
        let gammaSum = gamma.reduce(0.0, +)
        let thetaSum = theta.reduce(0.0, +)
        
        let data = [alphaSum, betaSum, deltaSum, gammaSum, thetaSum]
        
        setChart(dataPoints: data)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        chart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Logic
    
    func setChart(dataPoints: [Double]) {
        
        var dataEntries: [PieChartDataEntry] = []
        var labels = ["Relax", "Casual", "Sleep", "Thinking", "Relax++"]
        
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry.init(value: dataPoints[i], label: labels[i])
            dataEntries.append(dataEntry)
        }
        
        let set: PieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        
        set.colors = colors
        set.drawValuesEnabled = true
        
        let data: PieChartData = PieChartData(dataSet: set)
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1;
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %";
        
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        chart.data = data
        
    }
}

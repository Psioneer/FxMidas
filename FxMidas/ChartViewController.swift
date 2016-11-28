//
//  ChartViewController.swift
//  FxMidas
//
//  Created by KOBOKKYUNG on 2016. 11. 14..
//  Copyright © 2016년 Studio Psion. All rights reserved.
//

import UIKit
import Charts

class ChartViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var lineChartView: LineChartView!
    
    var months: [String]!
    var dollars1: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        dollars1 = [1453.0, 2352, 5431, 1442, 5451, 6486, 1173, 5678, 9234, 1345, 9411, 2212]
        
        self.lineChartView.delegate = self
        self.lineChartView.gridBackgroundColor = UIColor.darkGray
        self.lineChartView.noDataText = "No data provided"
        setChartData(months: months)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setChartData(months: [String]) {
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        for i in 0 ..< months.count {
            yVals1.append(ChartDataEntry(x: Double(i), y: dollars1[i], data: months[i] as AnyObject?))
        }
        
        let set1: LineChartDataSet = LineChartDataSet(values: yVals1, label: "First Set")
        set1.axisDependency = .left
        set1.setColor(UIColor.red.withAlphaComponent(0.5))
        set1.setCircleColor(UIColor.red)
        set1.lineWidth = 2.0
        set1.circleRadius = 6.0
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor.red
        set1.highlightColor = UIColor.white
        set1.drawCircleHoleEnabled = true
        
        var dataSets: [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        
        let data: LineChartData = LineChartData(dataSets: dataSets)
        data.setValueTextColor(UIColor.white)
        
        self.lineChartView.data = data
    }
}


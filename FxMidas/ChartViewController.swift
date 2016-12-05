//
//  ChartViewController.swift
//  FxMidas
//
//  Created by KOBOKKYUNG on 2016. 11. 14..
//  Copyright © 2016년 Studio Psion. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftyJSON


class ChartViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var candleStickChartView: CandleStickChartView!
    
    var aggregates:Array<Aggregate> = Array<Aggregate>()
    let dateFormatter = DateFormatter()
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(didEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        let notificationName = NSNotification.Name("StopChartTimer")
        notificationCenter.addObserver(self, selector: #selector(didEnterBackground), name: notificationName, object: nil)
    }
    
    func didEnterBackground() {
        if self.timer.isValid {
            self.timer.invalidate()
        }
    }
    
    func didBecomeActive() {
        startTimer()
    }
    
    func startTimer() {
        if timer == nil || !timer.isValid {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(self.tabBarController?.selectedViewController as Any)
        
        if self.tabBarController?.selectedViewController is ChartViewController {
            startTimer()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getAggregate(currency: "USD/JPY", interval: "60")
    }
    
    func runTimedCode() {
        getAggregate(currency: "USD/JPY", interval: "60")
    }
    
    func getAggregate(currency: String, interval: String) {
        let keychainItemWrapper = KeychainItemWrapper(identifier: "access info", accessGroup: nil)
        
        if let apiAccessToken = keychainItemWrapper["apiAccessToken"] as? String {
            let headers: HTTPHeaders = [
                "x-access-token": apiAccessToken
            ]
            
            let parameters = [
                "currency":currency,
                "interval":interval
            ]
            
            Alamofire.request("http://fmapi.japaneast.cloudapp.azure.com/api/aggregates", parameters: parameters, headers: headers).validate().responseJSON { response in
                switch response.result {
                case .failure(let error):
                    print(error)
                    
                case .success(let value):
                    let json = JSON(value)
                    self.aggregates.removeAll()
                                        
                    self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    for (_, aggr) in json {
                        let aggregate = Aggregate()
                        
                        aggregate.currency = aggr["currency"].string
                        aggregate.baseTime = self.dateFormatter.date(from: aggr["baseTime"].string!)
                        aggregate.highBid = aggr["maxBid"].number
                        aggregate.lowBid = aggr["minBid"].number
                        aggregate.openBid = aggr["inBid"].number
                        aggregate.closeBid = aggr["outBid"].number
                        aggregate.highAsk = aggr["maxAsk"].number
                        aggregate.lowAsk = aggr["minAsk"].number
                        aggregate.openAsk = aggr["inAsk"].number
                        aggregate.closeAsk = aggr["outAsk"].number

                        self.aggregates.append(aggregate)
                    }
                    
                    self.candleStickChartView.delegate = self
                    self.candleStickChartView.gridBackgroundColor = UIColor.darkGray
                    self.candleStickChartView.noDataText = "No data provided"
                    self.setChartData(aggregates: self.aggregates)
                }
            }
        } else {
            print("No access token!")
        }
 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setChartData(aggregates: [Aggregate]) {
        var yVals1 : [CandleChartDataEntry] = [CandleChartDataEntry]()
        
        var i: Int = 0
        for aggregate in aggregates {
            yVals1.append(CandleChartDataEntry(x: Double(i), shadowH: (aggregate.highBid?.doubleValue)!, shadowL: (aggregate.lowBid?.doubleValue)!, open: (aggregate.openBid?.doubleValue)!, close: (aggregate.closeBid?.doubleValue)!))
            i = i + 1
        }
        
        let set1: CandleChartDataSet = CandleChartDataSet(values: yVals1, label: "USD/JPY")
        
        var dataSets: [CandleChartDataSet] = [CandleChartDataSet]()
        dataSets.append(set1)
        
        let data: CandleChartData = CandleChartData(dataSets: dataSets)
        data.setValueTextColor(UIColor.white)
        
        self.candleStickChartView.data = data
    }
}


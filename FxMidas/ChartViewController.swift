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
    
    var baseTimes: [Date]!
    var lowBids: [Double]!
    var highBids: [Double]!
    var openBids: [Double]!
    var closeBids: [Double]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
/*
        getAggregate(currency: "USD/JPY", interval: "60")
        
        self.candleStickChartView.delegate = self
        self.candleStickChartView.gridBackgroundColor = UIColor.darkGray
        self.candleStickChartView.noDataText = "No data provided"
        setChartData(times: baseTimes)
*/
    }
    
    func getAggregate(currency: String, interval: String) {
        let keychainItemWrapper = KeychainItemWrapper(identifier: "access info", accessGroup: nil)
        
        if let apiAccessToken = keychainItemWrapper["apiAccessToken"] as? String {
            let headers: HTTPHeaders = [
                "x-access-token": apiAccessToken
            ]
            
            let parameters = [
                "currency":currency.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
                "interval":interval
            ]
            
            Alamofire.request("http://fmapi.japaneast.cloudapp.azure.com/api/aggregates", parameters: parameters, headers: headers).validate().responseJSON { response in
                switch response.result {
                case .failure(let error):
                    print(error)
                    
                case .success(let value):
                    let json = JSON(value)
/*                    self.aggregates.removeAll()
                                        
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
                        
                        self.baseTimes.append(self.dateFormatter.date(from: aggr["baseTime"].string!)!)
                        self.highBids.append(aggr["maxBid"].double!)
                        self.lowBids.append(aggr["minBid"].double!)
                        self.openBids.append(aggr["inBid"].double!)
                        self.closeBids.append(aggr["outBid"].double!)
                        
                        self.aggregates.append(aggregate)
                    }*/
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
    
    func setChartData(times: [Date]) {
        var yVals1 : [CandleChartDataEntry] = [CandleChartDataEntry]()
        for i in 0 ..< times.count {
            yVals1.append(CandleChartDataEntry(x: Double(times.count-1-i), shadowH: highBids[times.count-1-i], shadowL: lowBids[times.count-1-i], open: openBids[times.count-1-i], close: closeBids[times.count-1-i]))
        }
        
        let set1: CandleChartDataSet = CandleChartDataSet(values: yVals1, label: "USD/JPY")
        
        var dataSets: [CandleChartDataSet] = [CandleChartDataSet]()
        dataSets.append(set1)
        
        let data: CandleChartData = CandleChartData(dataSets: dataSets)
        data.setValueTextColor(UIColor.white)
        
        self.candleStickChartView.data = data
    }
}


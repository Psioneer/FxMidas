//
//  ChartViewController.swift
//  FxMidas
//
//  Created by KOBOKKYUNG on 2016. 11. 14..
//  Copyright © 2016년 Studio Psion. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func HttpRequest(address: String, mail: String, pass: String, phone: String, regKey: String) -> String{
        
        var text = "NO"
        let url = URL(string: address)
        var request = URLRequest(url: url!)
        let tmparam = ["email":mail,"password":pass, "phoneID":phone,"regKey":regKey]
        
        
        let postString = try! JSONSerialization.data(withJSONObject: tmparam, options: .init(rawValue: 0))
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
        request.httpBody = postString
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data,response,error in
            
            let httpResult = response as! HTTPURLResponse
            
            if httpResult.statusCode != 200
            {
                //let tmpInt = httpResult.statusCode
                text = "Error" //+ String(tmpInt)
            }
            
            do{
                
                let result = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                
                let returnCode = result["code"] as! Int
                //let base = result["baseInfo"] as! String
                //text = returnCode!
                text = String(returnCode)
                
                if text == "10003" {
                    text = "Mail Error"
                }
                
            } catch {
                text = "Error"
            }
            
        }
        )
        
        task.resume()
        
        while task.state.rawValue != 3 {
            sleep(1)
        }
        
        return text
    }
    
}


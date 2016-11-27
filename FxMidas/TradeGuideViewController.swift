//
//  TradeGuideViewController.swift
//  FxMidas
//
//  Created by KOBOKKYUNG on 2016. 11. 26..
//  Copyright © 2016년 Studio Psion. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TradeGuideViewController: UIViewController, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var transactionTableView: UITableView!
    @IBOutlet weak var currencyPairButton: UIButton!
    @IBOutlet weak var intervalButton: UIButton!
    @IBOutlet weak var currencyPairPickerView: UIPickerView!
    @IBOutlet weak var intervalPickerView: UIPickerView!
    
    var currencyPairs   = ["USD/JPY", "EUR/JPY", "EUR/USD", "AUD/JPY"]
    var intervalStrings = ["5 Minutes", "15 Minutes", "30 Minutes", "1 Hour"]
    var intervals       = ["05",        "15",         "30",         "60"]
    
    var transactions:Array<Transaction> = Array<Transaction>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        transactionTableView.delegate = self
        transactionTableView.dataSource = self
        
        currencyPairPickerView.isHidden = true
        currencyPairPickerView.selectRow(0, inComponent: 0, animated: true)
        intervalPickerView.isHidden = true
        intervalPickerView.selectRow(3, inComponent: 0, animated: true)
        
        currencyPairButton.setTitle(currencyPairs[0], for: .normal)
        intervalButton.setTitle(intervalStrings[3], for: .normal)
        
        let keychainItemWrapper = KeychainItemWrapper(identifier: "access info", accessGroup: nil)

        if let apiAccessToken = keychainItemWrapper["apiAccessToken"] as? String {
            let headers: HTTPHeaders = [
                "x-access-token": apiAccessToken
            ]
            
            let parameters = [
                "currency":currencyPairs[0].addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
                "interval":intervals[3]
            ]

            Alamofire.request("http://fmapi.japaneast.cloudapp.azure.com/api/transactions", parameters: parameters, headers: headers).validate().responseJSON { response in
                switch response.result {
                case .failure(let error):
                    print(error)
                    
                case .success(let value):
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let json = JSON(value)
                    for (index, trns) in json {
                        let transaction = Transaction()
                        
                        transaction.currency = trns["currency"].string
                        transaction.time = dateFormatter.date(from: trns["time"].string!)
                        transaction.amount = trns["amount"].float
                        transaction.decision = trns["decision"].string
                        transaction.profit = trns["profit"].float

                        self.transactions.append(transaction)
                    }
                    
                    for transaction in self.transactions {
                        print(transaction.currency! as Any)
                        print(dateFormatter.string(from: transaction.time!) as String)
                        print(transaction.amount! as Any)
                        print(transaction.decision! as Any)
                        print(transaction.profit! as Any)
                    }
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

    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return transactions.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = transactionTableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
     
        // Configure the cell...
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */

    // returns the number of 'columns' to display
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView!) -> Int {
        return 1
    }
    
    // returns the # of rows in each componet..
    func pickerView(_ pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows = 0
        
        if pickerView.tag == 0 {
            numberOfRows = currencyPairs.count
        } else if pickerView.tag == 1 {
            numberOfRows = intervalStrings.count
        }
        
        return numberOfRows
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent componet: Int) -> String? {
        var titleForRow = ""
        
        if pickerView.tag == 0 {
            titleForRow = currencyPairs[row]
        } else if pickerView.tag == 1 {
            titleForRow = intervalStrings[row]
        }
        return titleForRow
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            currencyPairButton.setTitle(currencyPairs[row], for: .normal)
            currencyPairPickerView.isHidden = true
        } else if pickerView.tag == 1 {
            intervalButton.setTitle(intervalStrings[row], for: .normal)
            intervalPickerView.isHidden = true
        }
    }
    
    @IBAction func selectCurrencyPair(_ sender: UIButton) {
        currencyPairPickerView.isHidden = !currencyPairPickerView.isHidden
    }
    
    @IBAction func selectInterval(_ sender: UIButton) {
        intervalPickerView.isHidden = !intervalPickerView.isHidden
    }
    
}


//
//  LoginViewController.swift
//  FxMidas
//
//  Created by KOBOKKYUNG on 2016. 11. 22..
//  Copyright © 2016년 Studio Psion. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        activityIndicator.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loginManagerDidComplete(_ result: LoginResult) {
        switch result {
        case .cancelled:
            print("User cancelled login.")
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        case .failed(let error):
            print(error)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        case .success(_, _, let accessToken):
            print(accessToken)
            
            let keychainItemWrapper = KeychainItemWrapper(identifier: "access info", accessGroup: nil)
            keychainItemWrapper["authenticationToken"] = accessToken.authenticationToken as AnyObject?
            keychainItemWrapper["userId"] = accessToken.userId as AnyObject?
            keychainItemWrapper["userType"] = "facebook" as AnyObject?
            
            let request = GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"], accessToken: accessToken, httpMethod: .GET, apiVersion: 2.8)
            request.start({ (httpResponse, result) in
                switch result {
                case .failed(let error):
                    print("Graph Request Failed: \(error)")
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                case .success(let response):
                    print("Graph Request Succeeded: \(response)")
                    if let responseDictionary = response.dictionaryValue {
                        print(responseDictionary["id"]!)
                        print(responseDictionary["name"]!)
                        print(responseDictionary["email"]!)

                        let uuidString = UIDevice.current.identifierForVendor!.uuidString

                        let parameters = [
                            "uuid"      : uuidString,
                            "name"      : responseDictionary["name"]!,
                            "email"     : responseDictionary["email"]!,
                            "userId"    : responseDictionary["id"]!,
                            "authToken" : accessToken.authenticationToken
                        ]
                        
                        Alamofire.request("http://fmapi.japaneast.cloudapp.azure.com/api/facebook/user", method: .post, parameters: parameters).validate().responseJSON { response in
                            switch response.result {
                            case .success(let data):
                                print(response.result.value! as Any)

                                let json = JSON(data)
                                let code = json["code"].intValue
                                
                                if (code == 0) {
                                    keychainItemWrapper["apiAccessToken"] = json["token"].stringValue as AnyObject?
                                    
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let controller = storyboard.instantiateViewController(withIdentifier: "TabBar")
                                    self.present(controller, animated: true, completion: nil)
                                } else if (code == 1) {
                                    // 틀린 계정 정보 경고창 표시
                                    print(json["message"].stringValue)
                                } else {
                                    // 데이터베이스 조회 장애
                                    print("Can not connect database system!")
                                }
                                
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.isHidden = true
                            case .failure(let error):
                                print(error)
                                
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.isHidden = true
                            }
                        }
                    }
                }
            })
        }
    }

    @IBAction func loginFacebook(_ sender: UIButton) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        let loginManager = LoginManager()
        loginManager.logIn([.publicProfile, .email], viewController: self, completion: {
            result in self.loginManagerDidComplete(result)
        })
        
    }
    
}

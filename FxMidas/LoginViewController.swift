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

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loginManagerDidComplete(_ result: LoginResult) {
        switch result {
        case .cancelled:
            print("User cancelled login.")
        case .failed(let error):
            print(error)
        case .success(_, _, let accessToken):
            print(accessToken)
            
            let keychainItemWrapper = KeychainItemWrapper(identifier: "access info", accessGroup: nil)
            keychainItemWrapper["authenticationToken"] = accessToken.authenticationToken as AnyObject?
            keychainItemWrapper["userId"] = accessToken.userId as AnyObject?
            
            let request = GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"], accessToken: accessToken, httpMethod: .GET, apiVersion: 2.8)
            request.start({ (httpResponse, result) in
                switch result {
                case .failed(let error):
                    print("Graph Request Failed: \(error)")
                case .success(let response):
                    print("Graph Request Succeeded: \(response)")
                    if let responseDictionary = response.dictionaryValue {
                        print(responseDictionary["id"]!)
                        print(responseDictionary["name"]!)
                        print(responseDictionary["email"]!)

                        let uuidString = UIDevice.current.identifierForVendor!.uuidString

                        let parameters = [
                            "userType"  : "facebook",
                            "uuid"      : uuidString,
                            "name"      : responseDictionary["name"]!,
                            "email"     : responseDictionary["email"]!,
                            "userId"    : responseDictionary["id"]!,
                            "authToken" : accessToken.authenticationToken
                        ]
                        
                        Alamofire.request("http://fmapi.japaneast.cloudapp.azure.com/api/facebook/user", method: .post, parameters: parameters).validate().responseJSON { response in
                            switch response.result {
                            case .success:
                                print(response.result.value! as Any)
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                }
            })
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "TabBar")
            self.present(controller, animated: true, completion: nil)
        }
    }

    @IBAction func loginFacebook(_ sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logIn([.publicProfile, .email], viewController: self, completion: {
            result in self.loginManagerDidComplete(result)
        })
        
    }
    
}

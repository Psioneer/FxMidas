//
//  SignupViewController.swift
//  FxMidas
//
//  Created by KOBOKKYUNG on 2016. 11. 26..
//  Copyright © 2016년 Studio Psion. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SignupViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signupEmail(_ sender: UIButton) {
        
        let uuidString = UIDevice.current.identifierForVendor!.uuidString
        
        let parameters = [
            "uuid"      : uuidString,
            "name"      : nameTextField.text!,
            "email"     : emailTextField.text!,
            "password"  : passwordTextField.text!
        ]
        
        Alamofire.request("http://fmapi.japaneast.cloudapp.azure.com/api/user", method: .post, parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .failure(let error):
                print(error)
            case .success(let data):
                print(data)
                
                let json = JSON(data)
                let code = json["code"].intValue
                let message = json["message"].stringValue
                
                if (code == 0) {
                    let keychainItemWrapper = KeychainItemWrapper(identifier: "access info", accessGroup: nil)
                    keychainItemWrapper["apiAccessToken"] = json["token"].stringValue as AnyObject?
                    keychainItemWrapper["userType"] = "email" as AnyObject?
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "TabBar")
                    self.present(controller, animated: true, completion: nil)
                } else {
                    // 등록 에러 경고 표시
                    print(message)
                }
            }
        }
    }
}


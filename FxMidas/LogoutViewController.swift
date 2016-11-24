//
//  LogoutViewController.swift
//  FxMidas
//
//  Created by 고복경 on 2016. 11. 24..
//  Copyright © 2016년 Studio Psion. All rights reserved.
//

import UIKit
import FacebookLogin

class LogoutViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LogoutFacebook(_ sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logOut()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginNavi")
        self.present(controller, animated: true, completion: nil)

    }
}


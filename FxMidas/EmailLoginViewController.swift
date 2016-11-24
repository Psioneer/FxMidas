//
//  EmailLoginViewController.swift
//  FxMidas
//
//  Created by KOBOKKYUNG on 2016. 11. 24..
//  Copyright © 2016년 Studio Psion. All rights reserved.
//

import UIKit

class EmailLoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
    }
}

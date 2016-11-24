//
//  RateViewController.swift
//  FxMidas
//
//  Created by KOBOKKYUNG on 2016. 11. 14..
//  Copyright © 2016년 Studio Psion. All rights reserved.
//

import UIKit

class RateViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let myUrl = URL(string: "http://webrates.truefx.com/rates/webWidget/trfxhp.jsp")
        let myRequest = URLRequest(url: myUrl!)
        webView.loadRequest(myRequest)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


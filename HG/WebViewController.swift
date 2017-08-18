//
//  WebViewController.swift
//  HG
//
//  Created by Andrew on 7/11/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    // Customise the nav bar
    let navBar = self.navigationController?.navigationBar
    navBar!.barTintColor = UIColor.black
    navBar!.tintColor = UIColor.white
    navBar!.isTranslucent = false
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
    let url = URL(string:"http://www.hyperemesis.org")
    webView.loadRequest(URLRequest(url: url!))
        
        
    }
    
    
    
    
}

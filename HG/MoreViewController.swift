//
//  MoreViewController.swift
//  HG
//
//  Created by Andrew on 7/10/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customise the nav bar
        let navBar = self.navigationController?.navigationBar
        navBar!.barTintColor = UIColor.black
        navBar!.tintColor = UIColor.white
        navBar!.isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]

        // Do any additional setup after loading the view.
    }
    


}

//
//  UnitViewController.swift
//  Fluid Tracker
//
//  Created by Andrew on 7/6/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit

class UnitViewController: UIViewController {

    @IBAction func oz(_ sender: Any) {
        UserDefaults.standard.set("oz", forKey: "measurementUnit")
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func ml(_ sender: Any) {
        UserDefaults.standard.set("ml", forKey: "measurementUnit")
        dismiss(animated: true, completion: nil)
    }
 

}

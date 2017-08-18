//
//  WeightViewController.swift
//  HG
//
//  Created by Andrew on 7/10/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class WeightViewController: UIViewController, UITextFieldDelegate {
     var days: [Day] = []
    var selectedDay: Day!
    
    @IBOutlet weak var weightField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weightField.text = String(selectedDay.weight)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        //save core data
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
      
        selectedDay.weight = Double(weightField.text!)!
        print(selectedDay.weight)
        do {
            try managedContext.save()
            //       days.append(day)
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // Dismiss if cancel is pressed
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

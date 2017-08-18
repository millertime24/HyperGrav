//
//  ReminderSchedulingViewController.swift
//  HG
//
//  Created by Andrew on 7/14/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit

class ReminderSchedulingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var deadlinePicker: UIDatePicker!
    
    
  
    
    @IBAction func savePressed(_ sender: UIButton) {
        let reminderItem = ReminderItem(deadline: deadlinePicker.date, title: titleField.text!, UUID: UUID().uuidString)
        ReminderList.sharedInstance.addItem(reminderItem) // schedule a local notification to persist this item
        let _ = self.navigationController?.popToRootViewController(animated: true) // return to list view
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleField.resignFirstResponder()
        return true
    }
    
    
}


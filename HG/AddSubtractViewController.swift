//
//  AddSubtractViewController.swift
//  Fluid Tracker
//
//  Created by Andrew on 7/5/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol AddSubtractDelegate {
    func addOrSubtractFluids(addOrSubtract: String, numberOfFluids: Int)
}

protocol EditDelegate {
    func updateTable()
}

class AddSubtractViewController: UIViewController, UITextFieldDelegate {
    
    // Used to know what function to perform
    // And how to change the view
    var addOrSubtract: String!
    
    // These are to get the data from them
    // Or change their data for different views
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var addSubtractButton: UIButton!
    @IBOutlet weak var fluidField: UITextField!
    
    
    // Delegates
    var addSubtractDelegate: AddSubtractDelegate?
    var editDelegate: EditDelegate?
    
    // Change the height for the EditHistory so I didn't have to make a new view
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var textFieldBottom: NSLayoutConstraint!
    
    // Variables for doing stuff with data
    var editDate: String!
    var editDay: NSManagedObject!
    var fluidGoal: String!
    
    override func viewDidLoad() {
        
        // Changing the appearance depending on the function
        if addOrSubtract == "Add" {
            topLabel.text = "Add fluids:"
            addSubtractButton.setTitle("Add", for: .normal)
            self.heightConstraint.constant = 142
            self.textFieldBottom.constant = 20
        }
        else if addOrSubtract == "Subtract" {
            topLabel.text = "Subtract fluids:"
            addSubtractButton.setTitle("Subtract", for: .normal)
            self.heightConstraint.constant = 142
            self.textFieldBottom.constant = 20
        }
        else if addOrSubtract == "ChangeGoal" {
            topLabel.text = "Fluid goal:"
            addSubtractButton.setTitle("Confirm", for: .normal)
            fluidField.text = ""
            self.heightConstraint.constant = 145
            self.textFieldBottom.constant = 20
        }
        else if addOrSubtract == "EditHistory" {
            topLabel.text = "Edit fluids for \(editDate!). Leave empty to exclude from average."
            fluidField.text = String(describing: editDay.value(forKey: "fluids")!)
            addSubtractButton.setTitle("Save", for: .normal)
            self.heightConstraint.constant = 175
            self.textFieldBottom.constant = 13
            if editDay.value(forKey: "notEntered") as! Bool == true {
                fluidField.text = ""
            }
        }
        
        // TextField delegate to limit number of characters allowed
       fluidField.delegate = self
        
        // Blur stuff for appearance
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.sendSubview(toBack: blurEffectView)
        
        super.viewDidLoad()
        
        view.subviews.first?.alpha = 0
    }
    
    // limits length input to 5 characters
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        
        if (textField.text?.characters.count)! >= 5 && range.length == 0 {
            return false
        }
        return true
    }
 
    // finishes animation for blurry background, also textField stuff
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fluidField.becomeFirstResponder()
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.subviews.first?.alpha = 1
        })
    }
    
    // The right button is pressed, and will perform an action
    @IBAction func addSubtractButtonPressed(_ sender: Any) {
        // If we're editing the history, we'll save the changes made, and update the history table
        if addOrSubtract == "EditHistory" {
            if self.fluidField.text == "" {
                self.editDay.setValue(true, forKey: "notEntered")
                self.editDay.setValue(0, forKey: "fluids")
                self.editDelegate?.updateTable()
            }
            else {
                self.editDay.setValue(false, forKey: "notEntered")
                self.editDay.setValue(Int(self.fluidField.text!), forKey: "fluids")
                self.editDelegate?.updateTable()
            }
        }
            // Else we're going to add, subtract, or change, then dismiss
        else {
            if self.fluidField.text == "" {
                dismiss(animated: true, completion: nil)
            }
            else {
                self.addSubtractDelegate?.addOrSubtractFluids(addOrSubtract: addOrSubtract, numberOfFluids: Int(fluidField.text!)!)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Dismiss if cancel is pressed
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

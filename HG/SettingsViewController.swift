//
//  SettingsViewController.swift
//  
//
//  Created by Andrew on 6/22/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit


class SettingsViewController: UIViewController {
    
//outlets
    
    @IBOutlet weak var textEnd: UITextField!
    
    @IBOutlet weak var buttonStartToday: UIButton!

    var dateFormatter: DateFormatter = DateFormatter()
    
    let endDatePicker : UIDatePicker = UIDatePicker();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customise the nav bar
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
        
        
        
        let model = self.modelData()
        
        // Setup date formatter
        self.dateFormatter.dateFormat = "EEE d MMM YYYY"
        
        
        self.textEnd.text = String(format: "%@", self.dateFormatter.string(from: model.end))
        
        
        
        self.endDatePicker.date = model.end
        self.endDatePicker.minimumDate = model.start
        self.endDatePicker.datePickerMode = UIDatePickerMode.date
        self.endDatePicker.addTarget(self, action: #selector(SettingsViewController.dateChanged(_:)), for: UIControlEvents.valueChanged)
        self.textEnd.inputView = self.endDatePicker
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func dateChanged(_ sender: AnyObject) {
        self.validateAndSaveModel()
    }
    
    //Action
    @IBAction func buttonStartTodayTouchUp(_ sender: AnyObject) {
        
        _ = self.modelData()
        
        self.validateAndSaveModel()
    }
    
    
    // Hides the keyboard if touch anywhere outside text box
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    
    // Hides the keyboard if return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    func validateAndSaveModel() {
        // Update the model
        let model = self.modelData()
        
        //   model.start = self.startDatePicker.date
        model.end = self.endDatePicker.date
        // Save this to userdefaults
        UserDefaults.standard.set(model.end, forKey: "endDate")
        
        // Update the text fields
        
        self.textEnd.text = String(format: "%@", self.dateFormatter.string(from: model.end))
        
        // Update the date restrictions too
        
        self.endDatePicker.minimumDate = model.start
        
        model.end = self.endDatePicker.date
        let calendar = NSCalendar.current
        var components = DateComponents()
        components.day = -280
        model.start = calendar.date(byAdding: components, to: model.end)!
        UserDefaults.standard.set(model.start, forKey: "startDate")
    }
    
    func modelData() -> DaysLeftModel {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.model
    }
    
    
}

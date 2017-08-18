//
//  DailyViewController.swift
//  HG
//
//  Created by Andrew on 7/10/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit
import CoreData


class DailyViewController: UIViewController, BEMCheckBoxDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
     var numbers = ["1", "2", "3", "4", "5", "6", "7", "8","9","10","11","12","13","14","15","16","17","18","19","20+"]
    
    var days: [Day] = []
    
    var selectedDate: Date!
    //var selectedDay: Day!
    
    var thisDay: Day!
    
    var weightlb: Int = 0
    
     // var emesisCount: Int = 0
    
    @IBOutlet weak var box: BEMCheckBox!
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var weightUnit: UILabel!
    
    @IBOutlet weak var picker: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect data:
        self.picker.delegate = self
        self.picker.dataSource = self
        
        
        print("viewDidLoad dailyView")
        //weightUnit.text = String(selectedDay.weight)
        
        // Customise the nav bar
        let navBar = self.navigationController?.navigationBar
        navBar!.barTintColor = UIColor.black
        navBar!.tintColor = UIColor.white
        navBar!.isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        box.delegate = self
        
        // returns the current date in Weekday, Month Day format
        dateLabel.text = convertDate(initialDate: selectedDate)
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numbers.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
        return numbers[row]
    }
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        
        //this will give you the number that user has selected
        //numbers array -> row -> title
        // store this number in a variable
        
        //emesis = numbers array -> row -> title
        //1 2 3 4
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let str = numbers[row]
        return NSAttributedString(string: str, attributes: [NSForegroundColorAttributeName:UIColor.white])
    }
    
    
    
    func didTap(_ checkBox: BEMCheckBox) {
        print("box tapped")

        //if it is false, set its value to true
        if thisDay.bowel == false {
            thisDay.setValue(true, forKey: "bowel")
        } else {
            //if it is true , set to false
            thisDay.setValue(false, forKey: "bowel")
            //
        }
        //save core data
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            try managedContext.save()
        }catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        
        
    }
    
    // returns Date in the user's timezone
    func fixDateThing() -> Date {
        let utcDate = Date()
        let timeZoneSeconds = NSTimeZone.local.secondsFromGMT(for: Date())
        let localDate = utcDate.addingTimeInterval(TimeInterval(timeZoneSeconds))
        return localDate
    }
    
    // convert date
    func convertDate(initialDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        let convertedDate = dateFormatter.string(from:initialDate)
        return convertedDate
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // save data
        if segue.identifier == "WeightSegue" {
            if let destination = segue.destination as? WeightViewController {
                destination.selectedDay = thisDay
            }
            
        } else if segue.identifier == "NotesSegue" {
            if let destination = segue.destination as? NotesViewController {
                destination.selectedDay = thisDay
            }
            
            
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setting up Core Data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Day")
        // Add predicate for day.dat == selectedDate
        let predicate = NSPredicate(format: "date == %@", argumentArray: [selectedDate])
        fetchRequest.predicate = predicate
        
        do {
            days = try managedContext.fetch(fetchRequest) as! [Day]
            if days.count == 0 {
                // create new Day
                
                let managedContext = appDelegate.persistentContainer.viewContext
                
                
                let entity = NSEntityDescription.entity(forEntityName: "Day", in: managedContext)!
                thisDay = NSManagedObject(entity: entity, insertInto: managedContext) as! Day
                thisDay.setValue(true, forKey: "notEntered")
                thisDay.setValue(selectedDate, forKeyPath: "date")
                // thisDay.emesis = emesis
                
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                print("must make new day")
            } else {
                // use this for the ui
                print("found a day")
                thisDay = days[0]
                weightUnit.text = ("\(thisDay.weight) lbs")
                // if bowel == true  // set the check mark image
                if thisDay.bowel == true {
                    box.setOn(true, animated: true)
                }
                
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
    }
    
}

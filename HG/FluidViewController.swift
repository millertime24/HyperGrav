//
//  FluidViewController.swift
//  HG
//
//  Created by Andrew on 7/10/17.
//  Copyright © 2017 Andrew. All rights reserved.
//  Based on simple calories

import UIKit
import CoreData

class FluidViewController: UIViewController {
    
    // The main circle view thing representing calories
    
    @IBOutlet var radialFluids: CircularProgressBar!
    
    // Delegate for getting number of calories from popup view
    var addOrSubtractDelegate: AddSubtractDelegate?
    
    // Various labels on the page for updating
    
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var averageLabel: UILabel!
    
    @IBOutlet weak var fluidsConsumedLabel: UILabel!
    
    @IBOutlet weak var fluidsRemainingLabel: UILabel!
    @IBOutlet weak var fluidGoalLabel: UILabel!
    
    @IBOutlet weak var fluidUnit: UILabel!
    
    
    
    
    // Variables represented on the labels
    var fluidGoal: Int = 100
    var fluidConsumed: Int = 0
    var ounces = "oz"
    var mil = "ml"
    
    // The store of days for the history
    var days: [NSManagedObject] = []
    // Dates used for automatically saving calories when the date changes
    var openDate: Date = Date()
    var closeDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Notifications to know when the app is closed or opened to check the date
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
        // More various setup stuff
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        radialFluids.theStrokeEnd = 0
        fluidGoal = 100
        fluidsConsumedLabel.text = "0"
        fluidsRemainingLabel.text = "100 remaining"
        calculateAverage()
        
        // This just returns the current date in Weekday, Month Day format
        dateLabel.text = convertDate(initialDate: fixDateThing())
        
        // This is all setup for the core data history stuff, so we can add to it and edit it
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Day")
        do {
            days = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // This gets data if the user has used the app before
        if (UserDefaults.standard.integer(forKey: "fluidConsumed") != 0) {
            self.fluidConsumed = UserDefaults.standard.integer(forKey: "fluidConsumed")
        }
        if (UserDefaults.standard.object(forKey: "closeDate") != nil) {
            closeDate = UserDefaults.standard.object(forKey: "closeDate") as! Date
        }
        if (UserDefaults.standard.integer(forKey: "fluidGoal") != 0) {
            fluidGoal = UserDefaults.standard.integer(forKey: "fluidGoal")
        }
        updateLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calculateAverage()
        if let unit = UserDefaults.standard.string(forKey: "measurementUnit") {
            fluidUnit.text = unit
        }
    }
    
    // Called when application resigns active, used for handling dates
    func appMovedToBackground() {
        // Set closeDate to openDate because that's what works, save to UserDefaults
        closeDate = self.openDate
        UserDefaults.standard.set(closeDate, forKey: "closeDate")
        print("app closed on \(convertDate(initialDate: closeDate))")
        // I think this print statement is preventing stuff from breaking
        print("the UserDefaults date is \(String(describing: UserDefaults.standard.value(forKey: "closeDate")))\n")
    }
    
    // Called when application starts or resumes, handles dates and automatically saving history
    func appMovedToForeground() {
        openDate = fixDateThing()
        dateLabel.text = convertDate(initialDate: openDate)
        
        // Gets the number of days between last time app was opened and now
        let skippedDays = daysBetween(startDate: closeDate, endDate: openDate)
        
      
        
        // If one day, just save yesterday, clear the circle thing, and reset the labels
        if skippedDays == 1 {
            let notEntered = UserDefaults.standard.bool(forKey: "notEntered")
            save(fluids: self.fluidConsumed, date: self.closeDate, notEntered: notEntered)
            UserDefaults.standard.set(true, forKey: "notEntered")
            fluidConsumed = 0
            updateLabels()
        }
            // If it's more than one day, iterate through them and save them to the history
        else if skippedDays > 1 {
            var tempDate = closeDate
            for i in 0..<skippedDays {
                if i == 0 {
                    let notEntered = UserDefaults.standard.bool(forKey: "notEntered")
                    save(fluids: self.fluidConsumed, date: tempDate, notEntered: notEntered)
                    UserDefaults.standard.set(true, forKey: "notEntered")
                    fluidConsumed = 0
                    updateLabels()
                }
                else {
                    save(fluids: 0, date: tempDate, notEntered: true)
                    
                }
                tempDate = tempDate.addingTimeInterval(60*60*24)
            }
        }
        calculateAverage()
        
    }
    
    // This is used for saving dates to Core Data
    func save(fluids: Int, date: Date, notEntered: Bool) {
        print("Should be saving \(fluids) fluids on date \(date)")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Day", in: managedContext)!
        let day = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // Save the given fluids and date
        day.setValue(fluids, forKey: "fluids")
        day.setValue(date, forKey: "date")
        day.setValue(notEntered, forKey: "notEntered")
        do {
            try managedContext.save()
            days.append(day)
        } catch let error as NSError {
            print("Something broke or whatever. \(error), \(error.userInfo)")
        }
    }
    
    
    // Used to update all the labels when they're changed
    func updateLabels() {
        fluidsConsumedLabel.text = String(fluidConsumed)
        if fluidGoal - fluidConsumed > 0 {
            fluidsRemainingLabel.text = String(fluidGoal - fluidConsumed) + " remaining"
        } else {
            fluidsRemainingLabel.text = "Goal completed"
        }
        let completeness: Double = Double(fluidConsumed) / Double(fluidGoal)
        radialFluids.animateStrokeEnd(toStroke: CGFloat(completeness))
        fluidGoalLabel.text = String(fluidGoal)
        UserDefaults.standard.set(fluidConsumed, forKey: "fluidConsumed")
        
    }
    
    func calculateAverage() {
        // Calculates the average of the last seven days
        // Only considers the ones that aren't empty
        if days.count > 0 {
            let lastSeven = days.suffix(7)
            var sum = 0
            var numDays = 0
            for day in lastSeven {
                let numCals = day.value(forKey: "fluids") as! Int
                if (day.value(forKey: "notEntered") as! Bool == false) {
                    sum += numCals
                    numDays += 1
                }
            }
            if numDays > 0 && sum > 0 {
                averageLabel.text = String(sum / numDays)
                averageLabel.alpha = 1.0
            }
            else if numDays == 0 {
                averageLabel.text = "Empty"
                averageLabel.alpha = 0.2
            }
            else {
                averageLabel.text = "0"
                averageLabel.alpha = 1.0
            }
        }
        else {
            averageLabel.text = "Empty"
            averageLabel.alpha = 0.2
        }
        
    }
    
    // Returns the number of days between two Dates because the actual method for it is garbage
    func daysBetween(startDate: Date, endDate: Date) -> Int {
        let currentCalendar = Calendar.current
        guard let startDate = currentCalendar.ordinality(of: .day, in: .era, for: startDate) else {
            return 0
        }
        guard let endDate = currentCalendar.ordinality(of: .day, in: .era, for: endDate) else {
            return 0
        }
        return endDate - startDate
        
    }
    
    // Just returns Date() in the user's timezone
    func fixDateThing() -> Date {
        let utcDate = Date()
        let timeZoneSeconds = NSTimeZone.local.secondsFromGMT(for: Date())
        let localDate = utcDate.addingTimeInterval(TimeInterval(timeZoneSeconds))
        return localDate
    }

    func convertDate(initialDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        let convertedDate = dateFormatter.string(from: Date())
        return convertedDate
    }
    
    // Doing stuff for segues, mainly passing information and setting delegates
    // addOrSubtract tells the view what action it will be performing
    // It should be addOrSubtractOrChange but I gave it more functions later
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddSegue" {
            UserDefaults.standard.set(false, forKey: "notEntered")
            if let destination = segue.destination as? AddSubtractViewController {
                destination.addOrSubtract = "Add"
                destination.addSubtractDelegate = self
            }
        }
        else if segue.identifier == "SubtractSegue" {
            print("Subtract button pressed")
            UserDefaults.standard.set(false, forKey: "notEntered")
            if let destination = segue.destination as? AddSubtractViewController {
                destination.addOrSubtract = "Subtract"
                destination.addSubtractDelegate = self
            }
        }
        else if segue.identifier == "ChangeGoal" {
            print("Changing goal")
            if let destination = segue.destination as? AddSubtractViewController {
                destination.fluidGoal = fluidGoalLabel.text
                destination.addOrSubtract = "ChangeGoal"
                destination.addSubtractDelegate = self
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


extension FluidViewController: AddSubtractDelegate {
    
    // perform different actions depending on what addOrSubtract says
    func addOrSubtractFluids(addOrSubtract: String, numberOfFluids: Int) {
        if addOrSubtract == "Add" {
            print("Adding \(numberOfFluids) fluids")
            fluidConsumed += numberOfFluids
        }
        else if addOrSubtract == "Subtract" {
            print("Subtracting \(numberOfFluids) fluids")
            fluidConsumed -= numberOfFluids
        }
        else if addOrSubtract == "ChangeGoal" {
            print("Changing goal to \(numberOfFluids)")
            self.fluidGoal = numberOfFluids
            UserDefaults.standard.set(numberOfFluids, forKey: "fluidGoal")
        }
        updateLabels()
    }
    
}

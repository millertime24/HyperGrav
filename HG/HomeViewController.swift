//
//  HomeViewController.swift
//  
//
//  Created by Andrew on 6/21/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit


class HomeViewController: UIViewController {
    @IBOutlet weak var labelDaysLeft: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var counterView: CounterView!
    @IBOutlet weak var labelStartDate: UILabel!
    @IBOutlet weak var labelEndDate: UILabel!
    @IBOutlet weak var labelPercentageDone: UILabel!
    @IBOutlet weak var counterWidth: NSLayoutConstraint!
    
    var dayChangeTimer: Timer!
    var shareButton: UIBarButtonItem!
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customise the nav bar
        let navBar = self.navigationController?.navigationBar
        navBar!.barTintColor = UIColor.black
        navBar!.tintColor = UIColor.white
        navBar!.isTranslucent = false
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        
        // Add a share button
        self.shareButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(HomeViewController.shareButtonTouchUp))
        
        self.navigationItem.leftBarButtonItem = shareButton
        
        self.counterView.clearControl()
        // check if we have the dates saved in the defaults
        if let startDate = UserDefaults.standard.value(forKey: "startDate") as? Date, let endDate = UserDefaults.standard.value(forKey: "endDate") as? Date {
            //we have the dates: update the UI
            updateViewForDates(start: startDate, end: endDate)
            
        } else {
            // you should go to the settings (don't forget to add the name to the segue!)
            performSegue(withIdentifier: "showDueDate", sender: self)
        }
        
        // Add timer in case runs over a day change
        let now = Date()
        let secondsInADay: Double = 60 * 60 * 24
        let startOfTomorrow = appdelegate.model.AddDays(appdelegate.model.StartOfDay(now), daysToAdd: 1)
        self.dayChangeTimer = Timer(fireAt: startOfTomorrow, interval: secondsInADay, target: self, selector: #selector(HomeViewController.dayChangedTimerFired), userInfo: nil, repeats: false)
    }

    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil, completion:{ context in self.counterView.updateControl() })
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if (previousTraitCollection == nil) {
            // Initialisation, so no need to update
            return
        }
        
        if (self.traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass || self.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass) {
            self.counterView.updateControl()
        }
    }
    
    func dayChangedTimerFired(_ timer: Timer) {
        // TAke care of this
        //self.updateViewFromModel()
    }
    
    func modelData() -> DaysLeftModel {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.model
    }
    
    
    func updateViewForDates(start: Date, end: Date) {
        
        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "EEE d MMM"
        
        // Set the start/end date
        self.labelStartDate.text = String(format: "%@", shortDateFormatter.string(from: start))
        self.labelEndDate.text = String(format: "%@", shortDateFormatter.string(from: end))
        
        // Calculate the days left
        let requestedComponent: Set<Calendar.Component> = [.day]
        let timeDifference = Calendar.current.dateComponents(requestedComponent, from: start, to: Date())
        debugPrint(timeDifference.day, "days")
        let difference = 280 - timeDifference.day!
        labelDaysLeft.text = String(format: "%d", abs(difference))
        // Set the correct label for the difference
        if difference >= 0 {
            labelTitle.text = "days left"
            if difference == 1 {
                labelTitle.text = "day left"
            }
        } else {
            labelTitle.text = "days overdue"
            if difference == -1 {
                labelTitle.text = "day overdue"
            }
        }
        
        // calculate the percentage done
        let percentageDone: Float = (Float(timeDifference.day!) * 100.0) / Float(280)
        self.labelPercentageDone.text = String(format:"%3.0f%% done", percentageDone)
        
        
        self.counterView.counter = timeDifference.day!
        self.counterView.maximumValue = 280
        self.counterView.updateControl()
        
    }
    
    
    func swipeLeft(_ gesture: UISwipeGestureRecognizer) {
        self.performSegue(withIdentifier: "segueShowSettings", sender: self)
    }
    
    
    func shareButtonTouchUp() {
        let modelText = self.modelData().FullDescription(Date())
        let objectsToShare = [modelText]
        
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        if (activityViewController.popoverPresentationController != nil) {
            activityViewController.popoverPresentationController!.barButtonItem = self.shareButton;
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
}


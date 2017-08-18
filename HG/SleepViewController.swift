//
//  SleepViewController.swift
//  HG
//
//  Created by Andrew on 8/14/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit
import HealthKit

class SleepViewController: UIViewController {
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet var displayTimeLabel: UILabel!
    
    var startTime = TimeInterval()
    var timer:Timer = Timer()
    var endTime: Date!
    var alarmTime: Date!
    
    let healthStore = HKHealthStore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let typestoRead = Set([
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
            ])
        
        let typestoShare = Set([
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
            ])
        
        self.healthStore.requestAuthorization(toShare: typestoShare, read: typestoRead) { (success, error) -> Void in
            if success == false {
                NSLog(" Display not allowed")
            }
        }
    }
    
    @IBAction func start(_ sender: AnyObject) {
        alarmTime = Date()
        if (!timer.isValid) {
            let aSelector : Selector = #selector(SleepViewController.updateTime)
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = Date.timeIntervalSinceReferenceDate
        }
    }
    
    @IBAction func stop(_ sender: AnyObject) {
        endTime = Date()
        
        self.saveSleepAnalysis()
        self.retrieveSleepAnalysis()
        
        timer.invalidate()
    }
    
    func updateTime() {
        let currentTime = Date.timeIntervalSinceReferenceDate
        
        //Find the difference between current time and start time.
        var elapsedTime: TimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        //minuets, seconds and milliseconds as assign it to the UILabel
        displayTimeLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
    }
    
    func saveSleepAnalysis() {
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            // create new object we want to Health app
            let inBedSample = HKCategorySample(type:sleepType, value: HKCategoryValueSleepAnalysis.inBed.rawValue, start: self.alarmTime, end: self.endTime)
            
            // put object to HealthStore
            
            healthStore.save(inBedSample, withCompletion: { (success, error) -> Void in
                
                if error != nil {
                    //error
                    return
                    
                }
                
                if success {
                    print("New data was saved in Healthkit")
                    
                } else {
                    //  error again
                }
                
            })
            
            
            let asleepSample = HKCategorySample(type:sleepType, value: HKCategoryValueSleepAnalysis.asleep.rawValue, start: self.alarmTime, end: self.endTime)
            
            
            healthStore.save(asleepSample, withCompletion: { (success, error) -> Void in
                
                if error != nil {
                    // error
                    return
                    
                }
                
                if success {
                    print("New data asleepSample was saved in Healthkit")
                    
                } else {
                    // error
                    
                }
                
            })
            
            
        }
    }
    
    func retrieveSleepAnalysis() {
        
        // startDate and endDate are NSDate objects
        
        // first, we define the object type we want
        
    if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            //let predicate = HKQuery.predicateForSamplesWithStartDate(startDate,endDate: endDate ,options: .None)
            
            // recent data first
            
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
        // the block completion to execute
            
        let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                if error != nil {
                    
                    // Handle the error in your app gracefully
                    return
                    
                }
                
                if let result = tmpResult {
                    
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                            
                            print("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(value)")
                        }
                    }
                }
            }
            
            
            healthStore.execute(query)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}


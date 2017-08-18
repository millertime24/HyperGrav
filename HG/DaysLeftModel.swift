//
//  DaysLeftModel.swift
//  
//
//  Created by Andrew on 6/22/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import Foundation


public class DaysLeftModel {
        public var start: Date = Date()
       public var end: Date = Date()
        public var title: String = ""
        public var weekdaysOnly: Bool = false
    
        public init() {
                // Defualt initialiser
        }
    
        open var DaysLength: Int {
                get {
            return self.DaysDifference(self.start as Date, endDate: self.end as Date) + 1; // Day count is inclusive, so add one to the total
                    }
            }
    
    open func DaysLeft(_ currentDate: Date) -> Int {
        let startCurrentDate = self.StartOfDay(currentDate)
        
        // If the current date is before the start, return the length
        if (startCurrentDate.compare(self.start as Date) == ComparisonResult.orderedAscending) {
            return self.DaysLength
        }
        
        // If the current date is after the end, return 0
        if (startCurrentDate.compare(self.end as Date) == ComparisonResult.orderedDescending) {
            return 0
        }
        
        // Otherwise, return the actual difference
        return self.DaysLength - self.DaysGone(startCurrentDate)
    }
    
    /// returns: The number of days from the start to the current date
    open func DaysGone(_ currentDate: Date) -> Int  {
        let startCurrentDate = self.StartOfDay(currentDate)
        
        // If the current date is before the start, return 0
        if (startCurrentDate.compare(self.start as Date) == ComparisonResult.orderedAscending) {
            return 0
        }
        
        // If the current date is after the end, return the length
        if (startCurrentDate.compare(self.end as Date) == ComparisonResult.orderedDescending) {
            return self.DaysLength
        }
        
        // Otherwise, return the actual difference
        return self.DaysDifference(self.start as Date, endDate: startCurrentDate) + 1 // Inclusive so add 1
    }
    
    fileprivate func DaysDifference(_ startDate: Date, endDate: Date) -> Int {
        let globalCalendar: Calendar = Calendar.autoupdatingCurrent
        
        let startOfStartDate = self.StartOfDay(startDate)
        let startOfEndDate = self.StartOfDay(endDate)
        
        // If want all days, just calculate the days difference and return it
        if (!self.weekdaysOnly) {
            let components: DateComponents = (globalCalendar as NSCalendar).components(NSCalendar.Unit.day, from: startOfStartDate, to: startOfEndDate, options: NSCalendar.Options.wrapComponents)
            
            return components.day!
        }
        
        // If we are calculating weekdays only, first adjust the start or end date if on a weekend
        var startDayOfWeek: Int = (globalCalendar as NSCalendar).component(NSCalendar.Unit.weekday, from: startOfStartDate)
        var endDayOfWeek: Int = (globalCalendar as NSCalendar).component(NSCalendar.Unit.weekday, from: startOfEndDate)
        
        var adjustedStartDate = startOfStartDate
        var adjustedEndDate = startOfEndDate
        
        // If start is a weekend, adjust to Monday
        if (startDayOfWeek == 7) {
            // Saturday
            adjustedStartDate = self.AddDays(startOfStartDate, daysToAdd: 2)
        } else if (startDayOfWeek == 1) {
            // Sunday
            adjustedStartDate = self.AddDays(startOfStartDate, daysToAdd: 1)
        }
        
        // If end is a weekend, move it back to Friday
        if (endDayOfWeek == 7) {
            // Saturday
            adjustedEndDate = self.AddDays(startOfEndDate, daysToAdd: -1)
        } else if (endDayOfWeek == 1) {
            // Sunday
            adjustedEndDate = self.AddDays(startOfEndDate, daysToAdd: -2)
        }
        
        let adjustedComponents: DateComponents = (globalCalendar as NSCalendar).components(NSCalendar.Unit.day, from: adjustedStartDate, to: adjustedEndDate, options: NSCalendar.Options.wrapComponents)
        
        let adjustedTotalDays: Int = adjustedComponents.day!
        let fullWeeks: Int = adjustedTotalDays / 7
        
        // Now we need to take into account if the day of the start date is before or after the day of the end date
        startDayOfWeek = (globalCalendar as NSCalendar).component(NSCalendar.Unit.weekday, from: adjustedStartDate)
        endDayOfWeek = (globalCalendar as NSCalendar).component(NSCalendar.Unit.weekday, from: adjustedEndDate)
        
        var daysOfWeekDifference = endDayOfWeek - startDayOfWeek
        if (daysOfWeekDifference < 0) {
            daysOfWeekDifference += 5
        }
        
        // Finally return the number of weekdays
        return (fullWeeks * 5) + daysOfWeekDifference
    }
    
    open func StartOfDay(_ fullDate: Date) -> Date {
        
        let startOfDayComponents =  (Calendar.current as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: fullDate)
        
        return Calendar.current.date(from: startOfDayComponents)!
    }
    
    open func AddDays(_ originalDate: Date, daysToAdd: Int) -> Date {
        var dateComponents: DateComponents = DateComponents()
        dateComponents.day = daysToAdd
        return (Calendar.current as NSCalendar).date(byAdding: dateComponents, to: originalDate, options: [])!
    }
    fileprivate func allCurrentSettings() -> Dictionary<String, AnyObject> {
        var updatedSettings = Dictionary<String, AnyObject>()
        updatedSettings["start"] = self.start as AnyObject?
        updatedSettings["end"] = self.end as AnyObject?
        updatedSettings["title"] = self.title as AnyObject?
        updatedSettings["weekdaysOnly"] = self.weekdaysOnly as AnyObject?
        
        return updatedSettings;
    }
    
    open func FullDescription(_ currentDate: Date) -> String {
        return String(format: "%d %@", self.DaysLeft(currentDate), self.Description(currentDate))
    }
    
    open func Description(_ currentDate: Date) -> String {
        let daysLeft: Int = self.DaysLeft(currentDate)
        
        var titleSuffix = "left"
        var titleDays = ""
        
        if (self.title.characters.count > 0) {
            titleSuffix = "until " + self.title
        }
        
        if (self.weekdaysOnly) {
            titleDays = (daysLeft == 1) ? "weekday" : "weekdays"
        } else {
            titleDays = (daysLeft == 1) ? "day" : "days"
        }
        
        return String(format: "%@ %@", titleDays, titleSuffix)
    }
    
    open func DaysLeftDescription(_ currentDate: Date) -> String {
        let daysLeft: Int = self.DaysLeft(currentDate)
        
        var titleDays = ""
        
        if (self.weekdaysOnly) {
            titleDays = (daysLeft == 1) ? "weekday" : "weekdays"
        } else {
            titleDays = (daysLeft == 1) ? "day" : "days"
        }
        
        return String(format: "%d %@", daysLeft, titleDays)
    }
    }

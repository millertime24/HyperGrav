//
//  ReminderItem.swift
//  HG
//
//  Created by Andrew on 7/14/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import Foundation

struct ReminderItem {
    
    var title: String
    var deadline: Date
    var UUID: String
    
    init(deadline: Date, title: String, UUID: String) {
        self.deadline = deadline
        self.title = title
        self.UUID = UUID
    }
    
    var isOverdue: Bool {
        return(Date().compare(self.deadline) == ComparisonResult.orderedDescending)
    }
    
    
}

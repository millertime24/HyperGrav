//
//  ReminderTableViewController.swift
//  HG
//
//  Created by Andrew on 7/14/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit
import UserNotifications

class ReminderTableViewController: UITableViewController {

    
    var reminderItems: [ReminderItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ReminderTableViewController.refreshList), name: NSNotification.Name(rawValue: "ReminderListShouldRefresh"), object: nil)
        
        // Customise the nav bar
        let navBar = self.navigationController?.navigationBar
        navBar!.barTintColor = UIColor.black
        navBar!.tintColor = UIColor.white
        navBar!.isTranslucent = false
        let titleDict: Dictionary<String, AnyObject> = [NSForegroundColorAttributeName: UIColor.white]
        navBar!.titleTextAttributes = titleDict
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshList()
    }
 
    func refreshList() {
        reminderItems = ReminderList.sharedInstance.allItems()
        if (reminderItems.count >= 64) {
            self.navigationItem.rightBarButtonItem!.isEnabled = false
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reminderItems.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        let reminderItem = reminderItems[(indexPath.row)] as ReminderItem
        cell.textLabel?.text = reminderItem.title as String!
        if (reminderItem.isOverdue) {
            cell.detailTextLabel?.textColor = UIColor.red
        } else {
            cell.detailTextLabel?.textColor = UIColor.black
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = " MMM dd 'at' h:mm a"
        cell.detailTextLabel?.text = dateFormatter.string(from: reminderItem.deadline as Date)
        
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let item = reminderItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            ReminderList.sharedInstance.removeItem(item)
            self.navigationItem.rightBarButtonItem!.isEnabled = true
            
        }
    }
    
    
    
}

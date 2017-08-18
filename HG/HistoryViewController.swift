//
//  HistoryViewController.swift
//  Fluid Tracker
//
//  Created by Andrew on 7/5/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // The tableView and data that will populate it
    @IBOutlet var tableView: UITableView!
    var days: [NSManagedObject] = []
    
    // These are passed through the segue I think
    var tappedCellDate: Date!
    var tappedCellDay: NSManagedObject!
    
    var editDelegate: EditDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setting up Core Data stuff
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
        
        // Sort the array because editing it makes it go out of order
        // Scroll to the bottom of the list
        if days.count > 0 {
            days.sort(by: { ($0.value(forKey: "date") as! Date).compare($1.value(forKey: "date") as! Date) == ComparisonResult.orderedAscending })
            tableView.setContentOffset(CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude), animated: false)
        }
        
        tableView.reloadData()
    }
    
    // Exits this view controller when X pressed
    @IBAction func xButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Reloads the tableView when the edit popup is dismissed
    func reloadTableStuff() {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    // Converts the dates to display them on the tableview cells
    func convertDate(initialDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")! as TimeZone
        dateFormatter.dateFormat = "EEEE, MMMM d"
        let convertedDate = dateFormatter.string(from: initialDate)
        return convertedDate
    }
    
    // Segues to edit view with the info from the tapped cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let day = days[indexPath.row]
        tappedCellDate = day.value(forKey: "date") as! Date
        tappedCellDay = day
        self.performSegue(withIdentifier: "EditHistory", sender: nil)
        tableView.reloadData()
    }
    
    // Preparing for segue to edit view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditHistory" {
            print("Editing history")
            if let destination = segue.destination as? AddSubtractViewController {
                destination.addOrSubtract = "EditHistory"
                destination.editDay = self.tappedCellDay
                destination.editDate = convertDate(initialDate: self.tappedCellDate)
                destination.editDelegate = self
            }
        }
    }
    
    // Putting the data in the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let day = days[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HistoryCell
        // Get date from Core Data and convert it to formatted string
        let newDate = convertDate(initialDate: day.value(forKey: "date") as! Date)
        let notEntered = day.value(forKey: "notEntered") as! Bool
        // Set everything, if no calories then set it empty
        cell.dateLabel.text = newDate
        cell.fluidsLabel.text = String(describing: day.value(forKey: "fluids")!)
        if notEntered {
            cell.fluidsLabel.text = "Empty"
            cell.fluidsLabel.alpha = 0.2
        }
        else {
            cell.fluidsLabel.alpha = 1.0
        }
        
        // Set the background image
        let imageView = UIImageView(frame: cell.contentView.frame)
        let image = UIImage(named: "CellBackground3")
        imageView.image = image
        cell.backgroundView = UIView()
        cell.backgroundView!.addSubview(imageView)
        
        return cell
        
    }
}

// Extension to reload the table when the edit view is dismissed
extension HistoryViewController: EditDelegate {
    func updateTable() {
        tableView.reloadData()
    }
}



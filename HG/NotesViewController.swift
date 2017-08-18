//
//  NotesViewController.swift
//  HG
//
//  Created by Andrew on 7/10/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit
import CoreData


class NotesViewController: UIViewController {
    
    var selectedDay: Day!

     @IBOutlet weak var notesField: UITextView!
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func save(_ sender: Any) {
     
        //save core data
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        selectedDay.notes = notesField.text
        
        do {
            try managedContext.save()
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
          notesField.text = selectedDay.notes
        
        // Customise the nav bar
      
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
    }
    
}

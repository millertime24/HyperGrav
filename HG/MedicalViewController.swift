//
//  MedicalViewController.swift
//  HG
//
//  Created by Andrew on 7/13/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit
import CoreData

class MedicalViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var medication: [NSManagedObject] = []
    
    
    @IBAction func back(_ sender: Any) {
        
      dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let navBar = self.navigationController?.navigationBar
        navBar!.barTintColor = UIColor.black
        navBar!.tintColor = UIColor.white
        navBar!.isTranslucent = false
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Medications")
        
        
        do {
            medication = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func addMed(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Medication",
                                      message: "Add Medication",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let medsToSave = textField.text else {
                    return
            }
            
            self.save(meds: medsToSave)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func save(meds: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let entity = NSEntityDescription.entity(forEntityName: "Medications", in: managedContext)!
        
        let medications = NSManagedObject(entity: entity, insertInto: managedContext)
        
        medications.setValue(meds, forKeyPath: "meds")
        
        do {
            try managedContext.save()
            medication.append(medications)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

extension MedicalViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medication.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            let medications = medication[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = medications.value(forKeyPath: "meds") as? String
            return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            medication.remove(at: indexPath.row)
            tableView.reloadData()
        }
        
    }
}

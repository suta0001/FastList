//
//  AllItemsTableViewController.swift
//  FastList
//
//  Created by Agustinus Sutandi and Abdullah Syed on 1/29/17.
//  Copyright © 2017 FastListTeam. All rights reserved.
//

import UIKit
import CoreData

class AllItemsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    let maxNumberOfItemsInSection = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeFetchedResultsController()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // To be modified later. Currently, we want 1 section only.
        if let section = fetchedResultsController.sections {
            if section.count > 1 {
                return section.count
            }
        }
        // To be modified later. Currently, we want 1 section only.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as? ItemTableViewCell else {
            fatalError("Incorrect TableViewCell instance.")
        }
        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.name
        }
        
        return nil
        //guard let sectionInfo = fetchedResultsController.sections?[section] else { fatalError("Unexpected Section") }
        //return sectionInfo.name
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let selectedObject = fetchedResultsController.object(at: indexPath) as? Item else { fatalError("Unexpected Object in FetchedResultsController") }
            fetchedResultsController.managedObjectContext.delete(selectedObject)
            if let location = selectedObject.locationTitle {
                if location != "" {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let managedObjectContext = appDelegate.coreDataManager.managedObjectContext
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Location")
                    request.predicate = NSPredicate(format: "locationTitle == %@", location)
                    request.returnsObjectsAsFaults = false
                    do {
                        let results = try managedObjectContext.fetch(request)
                        if results.count > 0 {
                            for result in results as! [NSManagedObject] {
                                if var count = result.value(forKey: "count") as? Int32 {
                                    if count > 1 {
                                        count = count - 1;
                                        result.setValue(count, forKey: "count")
                                    } else {
                                        appDelegate.stopMonitoring(title: result.value(forKey: "locationTitle") as! String, longitude: result.value(forKey: "locationLongitude") as! Double, latitude: result.value(forKey: "locationLatitude") as! Double)
                                        managedObjectContext.delete(result)
                                    }
                                }
                            }
                        }
                    } catch {
                        
                    }
                    
                }
            }
            
            do {
                // Save Managed Object Context
                try (UIApplication.shared.delegate as! AppDelegate).coreDataManager.managedObjectContext.save()
                
            } catch {
                print("Unable to save managed object context.")
            }
            //tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange: NSFetchedResultsSectionInfo, atSectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: atSectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: atSectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
        tableView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
            print("reload")
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
        tableView.reloadData()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddItem":
            break
        case "EditItem":
            guard let itemViewController = (segue.destination as? UINavigationController)?.topViewController as? ItemViewController else {
                fatalError("Destination not valid: \(segue.destination)")
            }
            
            guard let selectedCell = sender as? ItemTableViewCell else {
                fatalError("Sender not valid: \(sender)")
            }
            guard let indexPath = tableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            guard let selectedObject = fetchedResultsController.object(at: indexPath) as? Item else { fatalError("Unexpected Object in FetchedResultsController")
            }
            itemViewController.item = selectedObject
        default:
            fatalError("Invalid segue: \(segue.identifier)")
        }
    }
    
    // MARK: - Actions
    
    @IBAction func checkOffItem(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag % maxNumberOfItemsInSection, section: sender.tag / maxNumberOfItemsInSection)
        guard let selectedObject = fetchedResultsController.object(at: indexPath) as? Item else { fatalError("Unexpected Object in FetchedResultsController")
        }
        selectedObject.isCompleted = !selectedObject.isCompleted
        if selectedObject.completedDate == nil {
            selectedObject.completedDate = Date() as NSDate
        } else {
            selectedObject.completedDate = nil
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        do {
            // Save Managed Object Context
            try appDelegate.coreDataManager.managedObjectContext.save()
 
        } catch {
            print("Unable to save managed object context.")
        }
    }
    
    // MARK: - Helper functions
    
    func initializeFetchedResultsController() {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        let dateSort = NSSortDescriptor(key: "creationDate", ascending: true)
        //let predicate = NSPredicate(format: "isCompleted = false")
        
        request.sortDescriptors = [dateSort]
        //request.predicate = predicate
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let moc = appDelegate.coreDataManager.managedObjectContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
    }
    
    func configureCell(cell: ItemTableViewCell, indexPath: IndexPath) {
        guard let selectedObject = fetchedResultsController.object(at: indexPath) as? Item else { fatalError("Unexpected Object in FetchedResultsController") }
        cell.name.text = selectedObject.name
        //cell.name.textColor = UIColor.darkText
        //cell.statusButton.setTitleColor(UIColor.darkText, for: .normal)
        /*if let dueDate = selectedObject.dueDate as? Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            cell.detail.text = "Due: \(dateFormatter.string(from: dueDate))"
            cell.isOverdue = dueDate < Date()
        } else {
            cell.detail.text = ""
            cell.isOverdue = false
        }
        if selectedObject.locationTitle != "" {
            let location = selectedObject.locationTitle!
            if cell.detail.text != "" {
                cell.detail.text! += ", "
            }
            cell.detail.text! += "Location: \(location)"
        }*/
        cell.isCompleted = selectedObject.isCompleted
        let codedIndexPath = indexPath.section * maxNumberOfItemsInSection + indexPath.row
        cell.name.tag = codedIndexPath
        cell.detail.tag = codedIndexPath
        cell.statusButton.tag = codedIndexPath
    }
}

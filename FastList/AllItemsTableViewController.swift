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
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
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
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
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
            
            guard let button = sender as? UIButton else {
                fatalError("Sender not valid: \(sender)")
            }
            let indexPath = IndexPath(row: button.tag % maxNumberOfItemsInSection, section: button.tag / maxNumberOfItemsInSection)
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
        appDelegate.saveContext()
    }
    
    // MARK: - Helper functions
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        let dateSort = NSSortDescriptor(key: "creationDate", ascending: true)
        //let predicate = NSPredicate(format: "isCompleted = false")
        
        request.sortDescriptors = [dateSort]
        //request.predicate = predicate
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let moc = appDelegate.persistentContainer.viewContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    // MARK: - Private functions
    
    private func configureCell(cell: ItemTableViewCell, indexPath: IndexPath) {
        guard let selectedObject = fetchedResultsController.object(at: indexPath) as? Item else { fatalError("Unexpected Object in FetchedResultsController") }
        
        cell.name.setTitle(selectedObject.name, for: .normal)
        cell.name.setTitleColor(UIColor.darkText, for: .normal)
        cell.statusButton.setTitleColor(UIColor.darkText, for: .normal)
        if let dueDate = selectedObject.dueDate as? Date {
            if dueDate < Date() {
                cell.name.setTitleColor(UIColor.red, for: .normal)
                cell.statusButton.setTitleColor(UIColor.red, for: .normal)
            }
        }
        cell.isCompleted = selectedObject.isCompleted
        let codedIndexPath = indexPath.section * maxNumberOfItemsInSection + indexPath.row
        cell.name.tag = codedIndexPath
        cell.statusButton.tag = codedIndexPath
    }
}

//
//  FastListTableViewController.swift
//  FastList
//
//  Created by Agustinus Sutandi and Abdullah Syed on 1/29/17.
//  Copyright © 2017 FastListTeam. All rights reserved.
//

import UIKit
import CoreData
import MapKit


class FastListTableViewController:AllItemsTableViewController, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let location = appDelegate.currentLocation
        initializeFetchedResultsController(location: location)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    // MARK: - Location based Fast List


    
    // MARK: - Helper functions
    
    func initializeFetchedResultsController(location: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
       
        let hasDueDateSort = NSSortDescriptor(key: "hasDueDate", ascending: false)
        let dueDateSort = NSSortDescriptor(key: "dueDate", ascending: true)
        let dateSort = NSSortDescriptor(key: "creationDate", ascending: true)
        request.sortDescriptors = [hasDueDateSort, dueDateSort, dateSort]
        
        // Fetch based on location first
        var predicate = NSPredicate(format: "locationTitle = %@",location)
        request.predicate = predicate
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let moc = appDelegate.persistentContainer.viewContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
                predicate = NSPredicate(format: "locationTitle = %@","")
                request.predicate = nil
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        }
    }
    
    func reloadFetchedResultsController(location: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        let hasDueDateSort = NSSortDescriptor(key: "hasDueDate", ascending: false)
        let dueDateSort = NSSortDescriptor(key: "dueDate", ascending: true)
        let dateSort = NSSortDescriptor(key: "creationDate", ascending: true)
        let predicate = NSPredicate(format: "locationTitle = %@",location)
        
        request.sortDescriptors = [hasDueDateSort, dueDateSort, dateSort]
        request.predicate = predicate
        
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
    
}


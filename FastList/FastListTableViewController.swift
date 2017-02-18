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
    
<<<<<<< HEAD
    let futureDateToDisplayInSeconds = 2.0 * 3600 // Placeholder at 2 hours, will need to move to UserDefaults
=======
    let locationManager = CLLocationManager()
    let locationRadius = 1000
    var reloadTimer = Timer()
    let futureDateToDisplayInSeconds = 2.0 * 3600 / 60// Placeholder at 2 hours, will need to move to UserDefaults
>>>>>>> master
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let location = appDelegate.currentLocation
        initializeFetchedResultsController(location: location)
        NotificationCenter.default.addObserver(self, selector: #selector(FastListTableViewController.refreshView(notification:)), name: NSNotification.Name(rawValue: "refreshView"), object: nil)

        
<<<<<<< HEAD
=======
        initializeRegionMonitoring()
        initializeFetchedResultsController(location: "")
        
        reloadTimer = Timer.scheduledTimer(timeInterval: 0.1*futureDateToDisplayInSeconds, target: self, selector: #selector(FastListTableViewController.reloadTable), userInfo: nil, repeats: true)
>>>>>>> master
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Location based Fast List


    
    // MARK: - Helper functions
    
    func refreshView(notification: NSNotification) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let location = appDelegate.currentLocation
        initializeFetchedResultsController(location: location)
        tableView.reloadData()
    }
    
    func initializeFetchedResultsController(location: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
       
        let hasDueDateSort = NSSortDescriptor(key: "hasDueDate", ascending: false)
        let dueDateSort = NSSortDescriptor(key: "dueDate", ascending: true)
        let dateSort = NSSortDescriptor(key: "creationDate", ascending: true)
        request.sortDescriptors = [hasDueDateSort, dueDateSort, dateSort]
        
        // Fetch based on location first
        let locPredicate = NSPredicate(format: "locationTitle = %@", location)
        let maxDateToDisplay = Date(timeIntervalSinceNow: futureDateToDisplayInSeconds)
        let timePredicate = NSPredicate(format: "dueDate <= %@ OR hasDueDate = 0", maxDateToDisplay as NSDate)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [locPredicate, timePredicate])

        
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
            request.predicate = timePredicate
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        }
    }
    
    func reloadTable() {
        initializeFetchedResultsController(location: "")
        tableView.reloadData()
        print("Fire")
    }
    
}


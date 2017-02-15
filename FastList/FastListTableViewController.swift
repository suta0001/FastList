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
    let locationRadius = 1000
    let futureDateToDisplayInSeconds = 2.0 * 3600 // Placeholder at 2 hours, will need to move to UserDefaults
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        

        
        initializeRegionMonitoring()
        initializeFetchedResultsController(location: "")
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    // MARK: - Location based Fast List
    
    func initializeRegionMonitoring() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context1 = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Item")
        request.predicate = NSPredicate(format: "locationTitle != %@","")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context1.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "locationTitle") as? String {
                        let long = result.value(forKey: "locationLongitude")
                        let lat = result.value(forKey: "locationLatitude")
                        print("FastList: \(title) \(long) \(lat)")
                        let region = self.region(title: title, longitude: long as! Double, latitude: lat as! Double)
                        locationManager.startMonitoring(for: region)
                    }
                }
            }
        } catch {
            
        }
        
        
    }
    
    func region(title: String, longitude: Double, latitude: Double) -> CLCircularRegion {
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = CLCircularRegion(center: coordinate, radius: CLLocationDistance(locationRadius), identifier: title)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            initializeFetchedResultsController(location: region.identifier)
            handleEvent(forRegion: region)
            tableView.reloadData()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            initializeFetchedResultsController(location: "")
            tableView.reloadData()
        }
    }
    
    func handleEvent(forRegion region: CLRegion!) {
        print("Geofence triggered! for \(region.identifier)")
    }

    
    // MARK: - Helper functions
    
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
    
}


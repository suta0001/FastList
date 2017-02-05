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
    let locationRadius = 10
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeFetchedResultsController()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        

        
        initializeRegionMonitoring()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

}


extension FastListTableViewController  {

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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            
/*
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context1 = appDelegate.persistentContainer.viewContext
            let request1 = NSFetchRequest<NSFetchRequestResult>(entityName:"Item")
            request1.predicate = NSPredicate(format: "locationTitle = %@","\(region.identifier)")
            print(region.identifier)
            request1.returnsObjectsAsFaults = false
            do {
                let results = try context1.fetch(request1)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let title = result.value(forKey: "locationTitle") as? String {
                            let long = result.value(forKey: "locationLongitude")
                            let lat = result.value(forKey: "locationLatitude")
                            let name = result.value(forKey: "name")
                            print("FastList: \(title) \(long) \(lat) \(name)")
                            
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            let managedObjectContext = appDelegate.persistentContainer.viewContext
                            let item = self.fastListItem ?? (NSEntityDescription.insertNewObject(forEntityName: "FastListItem", into: managedObjectContext) as? FastListItem)
                            if let name1 = name as? String {
                                item!.name = name1
                            }
                            if let long1 = long as? Double {
                                item!.locationLongitude = long1
                            }
                            if let lat1 = lat as? Double {
                                item!.locationLatitude = lat1
                            }
                            item!.locationTitle = title
                            appDelegate.saveContext()
                        }
                    }
                }
            } catch {
                
            }*/
            handleEvent(forRegion: region)
            //tableView.reloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            //handleEvent(forRegion: region)
        }
    }
    
    func handleEvent(forRegion region: CLRegion!) {
        print("Geofence triggered! for \(region.identifier)")
    }
}


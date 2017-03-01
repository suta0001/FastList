//
//  AppDelegate.swift
//  FastList
//
//  Created by Agustinus Sutandi and Abdullah Syed on 1/25/17.
//  Copyright © 2017 FastListTeam. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import EventKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    var currentLocation = ""
    let category = ["Undefined","Grocery","Home Chores","Work Chores"]
    var currentLongtitude = 0.0
    var currentLatitude = 0.0
    var eventStore = EKEventStore()
    var calender:String? = nil
    var isAppInBackground = true
    var launchOpt:([UIApplicationLaunchOptionsKey: Any]?)
    var locationCurrentCL:CLLocation? = nil
    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        launchOpt = launchOptions
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()

        //initializeRegionMonitoring()
        
        //Prevent screen lock
        UIApplication.shared.isIdleTimerDisabled = UserDefaults.standard.bool(forKey: "idleTimerSetting")
        eventStore.requestAccess(to: EKEntityType.reminder, completion:
            {(granted, error) in
                if !granted {
                    print("Access to store not granted")
                }
                else {
                    print("Access to store granted")
                }
        })
        eventStore.requestAccess(to: EKEntityType.event, completion:
            {(granted, error) in
                if !granted {
                    print("Access to store not granted")
                }
                else {
                    print("Access to store granted")
                    self.checkAlarm()
        
                }
        })
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshView"), object: nil)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        UIApplication.shared.isIdleTimerDisabled = false
        isAppInBackground = true
        locationManager.stopUpdatingLocation()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.isIdleTimerDisabled = UserDefaults.standard.bool(forKey: "idleTimerSetting")
        let reminderObject = Reminder()
        locationManager.startUpdatingLocation()
        //reminderObject.removeReminderAlarm()
        isAppInBackground = false
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        UIApplication.shared.isIdleTimerDisabled = false
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "FastList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func checkAlarm() {
        let reminderObject = Reminder()
        if ((launchOpt?[UIApplicationLaunchOptionsKey.location]) != nil) {
            reminderObject.createLocationReminderTriggeredInMinute()
            isAppInBackground = true
        } else {
            reminderObject.removeReminderAlarm()
            isAppInBackground = false
        }
    }

}

extension AppDelegate : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            locationCurrentCL = location
            currentLatitude = location.coordinate.latitude
            currentLongtitude = location.coordinate.longitude
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshView"), object: nil)
            //print("location:: \(location)")
        }
        
    }
    /*
    func initializeRegionMonitoring() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context1 = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Location")
        //request.predicate = NSPredicate(format: "locationTitle != %@","")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context1.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "locationTitle") as? String {
                        let long = result.value(forKey: "locationLongitude")
                        let lat = result.value(forKey: "locationLatitude")
                        //let count = result.value(forKey: "count")
                        //print(count)
                        //print("FastList: \(title) \(long) \(lat)")
                        let region = self.region(title: title, longitude: long as! Double, latitude: lat as! Double)
                        locationManager.startMonitoring(for: region)
                    }
                }
            }
        } catch {
            
        }
        
        
    }*/
    
    func startMonitoring(title: String, longitude: Double, latitude: Double) {
        let reg = region(title: title, longitude: longitude, latitude: latitude)
        locationManager.startMonitoring(for: reg)
        print("Started Monitoring for")
        print(title)
        
    }
    
    func stopMonitoring(title: String, longitude: Double, latitude: Double) {
        let reg = region(title: title, longitude: longitude, latitude: latitude)
        locationManager.stopMonitoring(for: reg)
    }
    
    func region(title: String, longitude: Double, latitude: Double) -> CLCircularRegion {
        let locationRadius = 1000
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = CLCircularRegion(center: coordinate, radius: CLLocationDistance(locationRadius), identifier: title)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func handleEvent(forRegion region: CLRegion!) {
        print("Geofence triggered! for \(region.identifier)")
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if isAppInBackground {
            let reminderObject = Reminder()
            reminderObject.createLocationReminderTriggeredInMinute()
        }
        if region is CLCircularRegion {
            //FastListTableViewController.initializeFetchedResultsController(location: region.identifier)
            handleEvent(forRegion: region)
            currentLocation = region.identifier
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if isAppInBackground {
            let reminderObject = Reminder()
            reminderObject.createLocationReminderTriggeredInMinute()
        }
        if region is CLCircularRegion {
            //FastListTableViewController.initializeFetchedResultsController(location: "")
            if(currentLocation == region.identifier) {
                //currentLocation = ""
                //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshView"), object: nil)

            }
        }
    }
}


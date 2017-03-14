//
//  AppDelegate.swift
//  FastList
//
//  Created by Agustinus Sutandi and Abdullah Syed on 1/25/17.
//  Copyright © 2017 FastListTeam. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds
import CoreData
import CoreLocation
import EventKit
import Ensembles

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CDEPersistentStoreEnsembleDelegate {

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
    let coreDataManager = CoreDataManager(modelName: "FastList")
    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Firebase AdMob
        FIRApp.configure()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544~1458002511") // Need to update App ID after registering for AdMob account
        
        launchOpt = launchOptions
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()

        //initializeRegionMonitoring()
        
        
        
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
        
        // Use verbose logging for sync
        CDESetCurrentLoggingLevel(CDELoggingLevel.verbose.rawValue)
        
        
        // Create holder object if necessary. Ensure it is fully saved before we leech.
        _ = Item.numberHolderInContext(coreDataManager.managedObjectContext)
        _ = Location.numberHolderInContext(coreDataManager.managedObjectContext)
        try! coreDataManager.managedObjectContext.save()
        
        // Setup Ensemble
        let modelURL = Bundle.main.url(forResource: "FastList", withExtension: "momd")
        cloudFileSystem = CDEICloudFileSystem(ubiquityContainerIdentifier: nil)
        ensemble = CDEPersistentStoreEnsemble(ensembleIdentifier: "NumberStore", persistentStore: (coreDataManager.storeURL)!, managedObjectModelURL: modelURL!, cloudFileSystem: cloudFileSystem)
        ensemble.delegate = self
        
        // Listen for local saves, and trigger merges
        NotificationCenter.default.addObserver(self, selector:#selector(AppDelegate.localSaveOccurred(_:)), name:NSNotification.Name.CDEMonitoredManagedObjectContextDidSave, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(AppDelegate.cloudDataDidDownload(_:)), name:NSNotification.Name.CDEICloudFileSystemDidDownloadFiles, object:nil)

        // Sync
        self.sync(nil)
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
        self.sync(nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.isIdleTimerDisabled = UserDefaults.standard.bool(forKey: "idleTimerSetting")
        locationManager.startUpdatingLocation()
        isAppInBackground = false
        
        if UserDefaults.standard.bool(forKey: "syncReminderSetting") {
            let reminderObject = Reminder()
            reminderObject.syncReminders()
            /*
            DispatchQueue.global(qos: .userInteractive).async {
                DispatchQueue.main.async { 
                    let reminderObject = Reminder()
                    reminderObject.syncReminders()
                }
            }*/
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        UIApplication.shared.isIdleTimerDisabled = false
        let taskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        do {
            // Save Managed Object Context
            try self.coreDataManager.managedObjectContext.save()
        } catch {
            print("Unable to save managed object context.")
        }
        self.sync {
            UIApplication.shared.endBackgroundTask(taskIdentifier)
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
    
    // MARK: Notification Handlers
    
    func localSaveOccurred(_ notif: Notification) {
        self.sync(nil)
    }
    
    func cloudDataDidDownload(_ notif: Notification) {
        self.sync(nil)
    }
    
    // MARK: Ensembles
    
    var cloudFileSystem: CDECloudFileSystem!
    var ensemble: CDEPersistentStoreEnsemble!
    
    func sync(_ completion: ((Void) -> Void)?) {
        
        if !ensemble.isLeeched {
            ensemble.leechPersistentStore {
                error in
                completion?()
            }
        }
        else {
            ensemble.merge {
                error in
                completion?()
            }
        }
    }
    
    func persistentStoreEnsemble(_ ensemble: CDEPersistentStoreEnsemble, didSaveMergeChangesWith notification: Notification) {
        coreDataManager.managedObjectContext.performAndWait {
            self.coreDataManager.managedObjectContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    /*
    func persistentStoreEnsemble(_ ensemble: CDEPersistentStoreEnsemble!, globalIdentifiersForManagedObjects objects: [Any]!) -> [Any]! {
        var numberHolders:Any? = nil
        if let abc = objects as? [Item] {
            numberHolders = objects as! [Item]
        } else {
            numberHolders = objects as! [Location]
        }
        return numberHolders.map { $0.uniqueIdentifier }
    }*/

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


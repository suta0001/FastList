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
import EventKit


class FastListTableViewController:AllItemsTableViewController, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    var reloadTimer = Timer()
    var categoryAllowed = UserDefaults.standard.bool(forKey: "categorySetting")
    var futureDateToDisplayInSeconds = UserDefaults.standard.integer(forKey: "futureDateValueInSeconds") < 1 ? 7 * 24 * 60 * 60 : UserDefaults.standard.integer(forKey: "futureDateValueInSeconds")
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //reloadTable()
        NotificationCenter.default.addObserver(self, selector: #selector(FastListTableViewController.refreshView(notification:)), name: NSNotification.Name(rawValue: "refreshView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromUserDefaults(notification:)), name: UserDefaults.didChangeNotification, object: UserDefaults.standard)

        // Timer to reload FastList table every 60 s.
        reloadTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(FastListTableViewController.reloadTable), userInfo: nil, repeats: true)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Location based Fast List


    
    // MARK: - Helper functions
    
    func refreshView(notification: NSNotification) {
        reloadTable()
    }
    
    func initializeFetchedResultsController(lat: Double, long: Double) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context1 = appDelegate.persistentContainer.viewContext
        let request1 = NSFetchRequest<NSFetchRequestResult>(entityName:"Location")
        let dummy = "zzzzz"
        var locationPredict = NSPredicate(format: "locationTitle = %@",dummy)
        let radius = 0.001;
        print(lat)
        print(long)
        request1.predicate = NSPredicate(format:"locationLatitude > %f AND locationLatitude < %f AND locationLongitude > %f AND locationLongitude < %f", (lat - radius),  (lat + radius), (long - radius), (long + radius))
        request1.returnsObjectsAsFaults = false
        do {
            let results = try context1.fetch(request1)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "locationTitle") as? String {
                        let singleLocationPredict = NSPredicate(format: "locationTitle = %@",title)
                        locationPredict = NSCompoundPredicate(orPredicateWithSubpredicates: [singleLocationPredict, locationPredict])
                        /* Test
                        let long = result.value(forKey: "locationLongitude")
                        let lat = result.value(forKey: "locationLatitude")
                        print("Entered")
                        print("FastList: \(title) \(long) \(lat)")
                         */
                    }
                }
            }
        } catch {
            fatalError("Failed to fetch Location: \(error)")
        }
        
        let nameObject1 = UserDefaults.standard.object(forKey: "categorySetting")
        if let category = nameObject1 as? Bool {
            categoryAllowed = category
        }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
       
        let categoryLabelSort = NSSortDescriptor(key: "categoryLabel", ascending: true)
        let hasDueDateSort = NSSortDescriptor(key: "hasDueDate", ascending: false)
        let dueDateSort = NSSortDescriptor(key: "dueDate", ascending: true)
        let dateSort = NSSortDescriptor(key: "creationDate", ascending: true)
        
        if categoryAllowed {
            request.sortDescriptors = [categoryLabelSort, hasDueDateSort, dueDateSort, dateSort]
        } else {
            request.sortDescriptors = [hasDueDateSort, dueDateSort, dateSort]
        }
        
        
        let maxDateToDisplay = Date(timeIntervalSinceNow: Double(futureDateToDisplayInSeconds))
        let timePredicate = NSPredicate(format: "dueDate <= %@ OR hasDueDate = 0", maxDateToDisplay as NSDate)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [locationPredict, timePredicate])
        
        let moc = appDelegate.persistentContainer.viewContext
        if categoryAllowed {
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: "categoryLabel", cacheName: nil)
        } else {
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        }
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
        
        
        
        
        let request2 = NSFetchRequest<NSFetchRequestResult>(entityName:"Item")
        let timePredicate1 = NSPredicate(format: "dueDate > %@", maxDateToDisplay as NSDate)
        request2.sortDescriptors = [dueDateSort]
        request2.predicate = timePredicate1
        request2.returnsObjectsAsFaults = false
        do {
            let results = try context1.fetch(request2)
            if results.count > 0 {
                var firstTime = true
                for result in results as! [NSManagedObject] {
                    if firstTime {
                        firstTime = false
                        if var date = result.value(forKey: "dueDate") as? Date {
                            date.addTimeInterval(Double(-futureDateToDisplayInSeconds))
                            createReminder(setDate: date )
                        }
                    }
                }
            }
        } catch {
            fatalError("Failed to fetch Location: \(error)")
        }

        
    }
    
    func reloadTable() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let lat = appDelegate.currentLatitude
        let long = appDelegate.currentLongtitude
        initializeFetchedResultsController(lat:lat,long:long)
        //print(location)
        tableView.reloadData()
    }
    
    func updateFromUserDefaults(notification: Notification) {
        categoryAllowed = UserDefaults.standard.bool(forKey: "categorySetting")
        futureDateToDisplayInSeconds = UserDefaults.standard.integer(forKey: "futureDateValueInSeconds")
        reloadTable()
    }
    
    func createReminder(setDate: Date) {
        var alarmSet = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let eventStoreFastList = appDelegate.eventStore
        let predicate = eventStoreFastList.predicateForReminders(in: [])
        eventStoreFastList.fetchReminders(matching: predicate, completion: { (reminders: [EKReminder]?) -> Void in
            let reminders:[EKReminder] = reminders!
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let eventStoreFastList = appDelegate.eventStore
            if reminders.count != 0 {
            print("Reminders available")
            for reminder:EKReminder in reminders {
                let reminderTitle = "FastList is Updated"
                if reminder.title == reminderTitle {
                    for alarm in reminder.alarms! {
                        reminder.removeAlarm(alarm)
                    }
                    //reminder.alarms[0].
                    let alarm1 = EKAlarm(absoluteDate: setDate)
                    reminder.addAlarm(alarm1)
                    /*
                    let context1 = appDelegate.persistentContainer.viewContext
                    let request1 = NSFetchRequest<NSFetchRequestResult>(entityName:"Location")
                    request1.returnsObjectsAsFaults = false
                    do {
                        let results = try context1.fetch(request1)
                        if results.count > 0 {
                            for result in results as! [NSManagedObject] {
                                if let title = result.value(forKey: "locationTitle") as? String {
                                    let long = result.value(forKey: "locationLongitude")
                                    let lat = result.value(forKey: "locationLatitude")
                                    print("Entered")
                                    print("FastList: \(title) \(long) \(lat)")
                                    let location = EKStructuredLocation(title: "Current Location")
                                    location.geoLocation = CLLocation(latitude: lat as! CLLocationDegrees, longitude: long as! CLLocationDegrees)
                                    let alarm2 = EKAlarm()
                                    alarm2.structuredLocation = location
                                    alarm2.proximity = EKAlarmProximity.enter
                                    reminder.addAlarm(alarm2)
                                }
                            }
                        }
                    } catch {
                        fatalError("Failed to fetch Location: \(error)")
                    }
 */
                    do {
                        try eventStoreFastList.save(reminder,commit: true)
                        alarmSet = true
                    } catch let error {
                        print("Reminder failed with error \(error.localizedDescription)")
                        }
                    }
                }
            }
            if !alarmSet {
                let reminder = EKReminder(eventStore: eventStoreFastList)
                reminder.title = "FastList is Updated"
                reminder.calendar = eventStoreFastList.defaultCalendarForNewReminders()
                let alarm = EKAlarm(absoluteDate: setDate)
                reminder.addAlarm(alarm)
                /*
                let context1 = appDelegate.persistentContainer.viewContext
                let request1 = NSFetchRequest<NSFetchRequestResult>(entityName:"Location")
                request1.returnsObjectsAsFaults = false
                do {
                    let results = try context1.fetch(request1)
                    if results.count > 0 {
                        for result in results as! [NSManagedObject] {
                            if let title = result.value(forKey: "locationTitle") as? String {
                                let long = result.value(forKey: "locationLongitude")
                                let lat = result.value(forKey: "locationLatitude")
                                print("Entered")
                                print("FastList: \(title) \(long) \(lat)")
                                let location = EKStructuredLocation(title: "Current Location")
                                location.geoLocation = CLLocation(latitude: lat as! CLLocationDegrees, longitude: long as! CLLocationDegrees)
                                let alarm2 = EKAlarm()
                                alarm2.structuredLocation = location
                                alarm2.proximity = EKAlarmProximity.enter
                                reminder.addAlarm(alarm2)
                            }
                        }
                    }
                } catch {
                    fatalError("Failed to fetch Location: \(error)")
                }
 */
                do {
                    try eventStoreFastList.save(reminder,
                                                commit: true)
                } catch let error {
                    print("Reminder failed with error \(error.localizedDescription)")
                }
            }
        })
        
        
    }
}


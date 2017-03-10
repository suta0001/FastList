//
//  Reminder.swift
//  FastList
//
//  Created by Abdullah on 2/26/17.
//  Copyright © 2017 FastListTeam. All rights reserved.
//

import UIKit
import EventKit
import CoreData

class Reminder {
    
    weak var item: Item?
    weak var location: Location?
    
    public func createReminder(setDate: Date) {
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
                        if reminder.hasAlarms {
                        for alarm in reminder.alarms! {
                            reminder.removeAlarm(alarm)
                            }}
                        let alarm1 = EKAlarm(absoluteDate: setDate)
                        reminder.addAlarm(alarm1)
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
                do {
                    try eventStoreFastList.save(reminder,
                                                commit: true)
                } catch let error {
                    print("Reminder failed with error \(error.localizedDescription)")
                }
            }
        })
    }
    
    public func removeReminderAlarm() {
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
                        if reminder.hasAlarms {
                        for alarm in reminder.alarms! {
                            reminder.removeAlarm(alarm)
                        }
                        do {
                            try eventStoreFastList.save(reminder,commit: true)
                        } catch let error {
                            print("Reminder failed with error \(error.localizedDescription)")
                        }
                        }
                    }
                }
            }
        })
    }
    
    func createLocationReminderTriggeredInMinute() {
        var currentDate = Date()
        currentDate.addTimeInterval(Double(100))
        createReminder(setDate: currentDate)
    }
    
    public func syncReminders(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let eventStoreFastList = appDelegate.eventStore
        let predicate = eventStoreFastList.predicateForReminders(in: [])
        eventStoreFastList.fetchReminders(matching: predicate, completion: { (reminders: [EKReminder]?) -> Void in
            let reminders:[EKReminder] = reminders!
            if let lastReminderSynDate = UserDefaults.standard.object(forKey: "reminderSyncTill") as? Date {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if reminders.count != 0 {
                    print("Reminders available")
                    for reminder:EKReminder in reminders {
                        if lastReminderSynDate < reminder.creationDate! {
                            if !reminder.isCompleted {
                                let managedObjectContext = appDelegate.persistentContainer.viewContext
                                let Category = appDelegate.category
                                weak var item: Item?
                                weak var location: Location?
                                if item == nil {
                                    item = (NSEntityDescription.insertNewObject(forEntityName: "Item", into: managedObjectContext) as! Item)
                                    item!.isCompleted = false
                                    item!.creationDate = Date() as NSDate
                                    item!.completedDate = nil
                                    item!.hasDueDate = 0
                                    item!.locationTitle = ""
                                    item!.categoryLabel = Category[0]
                                }
                                
                                item!.name = reminder.title
                                if let due = reminder.alarms?[0].absoluteDate{
                                    
                                    item!.dueDate = due as NSDate
                                    item!.hasDueDate = 1
                                }
                                
                                if let setLocation = reminder.alarms?[0].structuredLocation{
                                    item!.locationTitle = setLocation.title
                                    
                                    let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Location")
                                    request.predicate = NSPredicate(format: "locationTitle == %@",setLocation.title)
                                    request.returnsObjectsAsFaults = false
                                    do {
                                        let results = try managedObjectContext.fetch(request)
                                        if results.count > 0 {
                                            for result in results as! [NSManagedObject] {
                                                if var count = result.value(forKey: "count") as? Int32 {
                                                    count = count + 1;
                                                    result.setValue(count, forKey: "count")
                                                }
                                            }
                                        } else {
                                            location = (NSEntityDescription.insertNewObject(forEntityName: "Location", into: managedObjectContext) as! Location)
                                            location!.locationTitle = setLocation.title
                                            location!.locationLatitude = setLocation.geoLocation!.coordinate.latitude
                                            location!.locationLongitude = setLocation.geoLocation!.coordinate.longitude
                                            location!.count = 1
                                            appDelegate.startMonitoring(title: location!.locationTitle!, longitude: location!.locationLatitude, latitude: location!.locationLongitude)
                                            
                                        }
                                    } catch {
                                    }
                                }
                                appDelegate.saveContext()
                            }
                        }
                    }
                }
            } else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if reminders.count != 0 {
                    print("Reminders available")
                    for reminder:EKReminder in reminders {
                        if !reminder.isCompleted {
                            let managedObjectContext = appDelegate.persistentContainer.viewContext
                            let Category = appDelegate.category
                            weak var item: Item?
                            weak var location: Location?
                            if item == nil {
                                item = (NSEntityDescription.insertNewObject(forEntityName: "Item", into: managedObjectContext) as! Item)
                                item!.isCompleted = false
                                item!.creationDate = Date() as NSDate
                                item!.completedDate = nil
                                item!.hasDueDate = 0
                                item!.locationTitle = ""
                                item!.categoryLabel = Category[0]
                                
                            }
                            
                            item!.name = reminder.title
                            if let due = reminder.alarms?[0].absoluteDate{
                                
                                item!.dueDate = due as NSDate
                                item!.hasDueDate = 1
                            }
                            
                            if let setLocation = reminder.alarms?[0].structuredLocation{
                                item!.locationTitle = setLocation.title
                                
                                let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Location")
                                request.predicate = NSPredicate(format: "locationTitle == %@",setLocation.title)
                                request.returnsObjectsAsFaults = false
                                do {
                                    let results = try managedObjectContext.fetch(request)
                                    if results.count > 0 {
                                        for result in results as! [NSManagedObject] {
                                            if var count = result.value(forKey: "count") as? Int32 {
                                                count = count + 1;
                                                result.setValue(count, forKey: "count")
                                            }
                                        }
                                    } else {
                                        location = (NSEntityDescription.insertNewObject(forEntityName: "Location", into: managedObjectContext) as! Location)
                                        location!.locationTitle = setLocation.title
                                        location!.locationLatitude = setLocation.geoLocation!.coordinate.latitude
                                        location!.locationLongitude = setLocation.geoLocation!.coordinate.longitude
                                        location!.count = 1
                                        appDelegate.startMonitoring(title: location!.locationTitle!, longitude: location!.locationLatitude, latitude: location!.locationLongitude)
                                        
                                    }
                                } catch {
                                }
                            }
                            appDelegate.saveContext()
                        }
                        
                    }
                }
            }
            let currentDate = Date()
            UserDefaults.standard.set(currentDate,forKey: "reminderSyncTill")
        })
    }
}

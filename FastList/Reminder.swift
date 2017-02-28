//
//  Reminder.swift
//  FastList
//
//  Created by Abdullah on 2/26/17.
//  Copyright © 2017 FastListTeam. All rights reserved.
//

import UIKit
import EventKit

class Reminder {
    
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
}

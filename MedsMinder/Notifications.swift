//
//  Notifications.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/28/21.
//

import Foundation
import UserNotifications

public class LocalNotificationManager: ObservableObject {
    var notifications = [Notification]()
        
    var permissionGranted: Bool = false

    func checkPermissions() -> Bool {
        print("permissionGranted at start: \(permissionGranted)")
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            print("permissionGranted after getting notification settings: \(self.permissionGranted)")

            guard (settings.authorizationStatus == .authorized) ||
                  (settings.authorizationStatus == .provisional) else { return }

            if settings.alertSetting == .enabled {
                self.permissionGranted = true
                print("permissionGranted at end successful: \(self.permissionGranted)")

            } else {
                self.permissionGranted = false
                print("permissionGranted at end unsuccessful: \(self.permissionGranted)")

            }
        }
        return permissionGranted
    }
    
    func listScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in

            for notification in notifications {
                print(notification)
            }
        }
    }

    func schedule(reminderData: [Reminder], medData: [Med])
    {
        UNUserNotificationCenter.current().getNotificationSettings { settings in

            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(reminderData: reminderData, medData: medData)
            case .authorized, .provisional:
                self.scheduleNotifications(reminderData: reminderData, medData: medData)
            default:
                break // Do nothing
            }
        }
    }
    
    
    func requestAuthorization(reminderData: [Reminder], medData: [Med])
    {
        if self.permissionGranted == false {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in

                if granted == true && error == nil {
                    self.permissionGranted = true
                    self.scheduleNotifications(reminderData: reminderData, medData: medData)
                }
            }
        }

    }
    
    func scheduleNotifications(reminderData: [Reminder], medData: [Med]) {
        if self.permissionGranted == false {
            self.requestAuthorization(reminderData: reminderData, medData: medData)
        }
        self.getNotifications(reminders: reminderData, meds: medData)

        for notification in notifications
        {
            let content      = UNMutableNotificationContent()
            content.title    = notification.title
            content.sound    = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.datetime, repeats: true)

            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in

                guard error == nil else { return }

                print("Notification scheduled! --- ID = \(notification.id)")
            }
        }
    }
    
    func getNotifications(reminders: [Reminder], meds: [Med]) {
        var count = 0
        let today = Foundation.Date()
        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: today)
        print(todayComponents)
        
        if reminders.count > 0 {
            for reminder in reminders {
//                if reminder.scheduled ?? false && med.reminders.count > 0 {
//                    let reminders = med.reminders
//                    for reminder in reminders {
                let med = meds.filter{ $0.name == reminder.medName}
//                print("this is the med: \(med)")
                count += 1
                let reminderComponents = Calendar.current.dateComponents([.hour, .minute], from: reminder.intakeTime)
                let newTime = Notification(id: "reminder #\(count)", title: "Take \(reminder.medName)", datetime: DateComponents(calendar: Calendar.current, year: todayComponents.year, month: todayComponents.month, day: todayComponents.day, hour: reminderComponents.hour, minute: reminderComponents.minute), image: med[0])
                notifications.append(newTime)
            }
        }
    }
}



public struct Notification {
    var id: String
    var title: String
    var datetime: DateComponents
    var image: Med
}

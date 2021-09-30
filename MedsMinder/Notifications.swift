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
        
//        = [
//        Notification(id: "reminder-1", title: "Remember the milk!", datetime: DateComponents(calendar: Calendar.current, year: 2021, month: 9, day: 29, hour: 13, minute: 24)),
//        Notification(id: "reminder-2", title: "Ask Bob from accounting", datetime: DateComponents(calendar: Calendar.current, year: 2021, month: 9, day: 29, hour: 13, minute: 26)),
//        Notification(id: "reminder-3", title: "Send postcard to mom", datetime: DateComponents(calendar: Calendar.current, year: 2021, month: 9, day: 29, hour: 13, minute: 27))
//    ]
    var permissionGranted: Bool = false
    
    func checkPermissions() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                  (settings.authorizationStatus == .provisional) else { return }

            if settings.alertSetting == .enabled {
                self.permissionGranted = true
            } else {
                self.permissionGranted = false
            }
        }
    }
    
    func listScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in

            for notification in notifications {
                print(notification)
            }
        }
    }

    func schedule(data: [Med])
    {
        UNUserNotificationCenter.current().getNotificationSettings { settings in

            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(data: data)
            case .authorized, .provisional:
                self.scheduleNotifications(data: data)
            default:
                break // Do nothing
            }
        }
    }
    
    private func requestAuthorization(data: [Med])
    {
        if self.permissionGranted == false {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in

                if granted == true && error == nil {
                    self.permissionGranted = true
                    self.scheduleNotifications(data: data)
                }
            }
        }

    }
    
    func scheduleNotifications(data: [Med]) {
        print("here we are in notifications, func scheduleNotifications \(data)")
        self.getNotifications(meds: data)

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
    
    func getNotifications(meds: [Med]) {
        var count = 0
        let today = Date()
        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: today)
        print(todayComponents)
        
        for med in meds {
            if med.scheduled! {
                let reminders = med.reminders[0].intakeTimes
                
                for reminder in reminders {
                    count += 1
                    let reminderComponents = Calendar.current.dateComponents([.hour, .minute], from: reminder)
                    let newTime = Notification(id: "reminder #\(count)", title: "take \(med.name)", datetime: DateComponents(calendar: Calendar.current, year: todayComponents.year, month: todayComponents.month, day: todayComponents.day, hour: reminderComponents.hour, minute: reminderComponents.minute))
                    notifications.append(newTime)
                }
            }
        }
    }
}



public struct Notification {
    var id: String
    var title: String
    var datetime: DateComponents
}

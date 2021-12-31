//
//  Notifications.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/28/21.
//

import Foundation
import UserNotifications

// TODO: Define public interface and mark others as private (do you need to mark as private?)
public class LocalNotificationManager {
  var permissionGranted: Bool = false

  static let sharedNotificationManager = LocalNotificationManager()

  func schedule(viewModel: ViewModel) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      switch settings.authorizationStatus {
      case .notDetermined:
        self.requestAuthorization()
        self.schedule(viewModel: viewModel)
      case .authorized, .provisional:
        self.scheduleNotifications(viewModel: viewModel)
      default:
        break  // Do nothing
      }
    }
  }

  func requestAuthorization() {
    if self.permissionGranted == false {
      UNUserNotificationCenter.current().requestAuthorization(options: [
        .alert, .badge, .sound,
      ]) {
        granted, error in

        if granted == true && error == nil {
          self.permissionGranted = true
        }
      }
    }
  }

  func listScheduledNotifications() {
    UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in

      print("Notifications: ")
      for notification in notifications {
        print(notification)
      }
    }
  }

  private func scheduleNotifications(viewModel: ViewModel) {
    let notifications = self.notifications(viewModel: viewModel)
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

    for notification in notifications {
      let content = UNMutableNotificationContent()
      content.title = notification.title
      content.sound = .default

      let trigger = UNCalendarNotificationTrigger(
        dateMatching: notification.datetime, repeats: true)

      let request = UNNotificationRequest(
        identifier: notification.id, content: content, trigger: trigger)

      UNUserNotificationCenter.current().add(request) { error in
        guard error == nil else { return }
      }
    }
  }

  private func notifications(viewModel: ViewModel) -> [Notification] {
    let calendar = Calendar.current
    // Use the following line if you want midnight UTC instead of local time
    //calendar.timeZone = TimeZone(secondsFromGMT: 0)
    let today = Date()
    let midnight = calendar.startOfDay(for: today)
    let datesToSchedule = [
      midnight,
      calendar.date(byAdding: .day, value: 1, to: midnight)!,
      calendar.date(byAdding: .day, value: 2, to: midnight)!,
    ]

    var notifications: [Notification] = []
    if viewModel.reminders.count > 0 {
      for reminder in viewModel.reminders {
        if let medication = viewModel.medication(for: reminder) {
          let reminderComponents = Calendar.current.dateComponents(
            [.hour, .minute], from: reminder.intakeTime)
          for date in datesToSchedule {
            let dayComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
            let reminderDateComponents = DateComponents(
              calendar: Calendar.current, year: dayComponents.year,
              month: dayComponents.month,
              day: dayComponents.day, hour: reminderComponents.hour,
              minute: reminderComponents.minute)
            let reminderTime = calendar.date(from: reminderDateComponents)!
            if reminderTime > Date() {
              let notification = Notification(
                title: "Take \(medication.name)",
                datetime: reminderDateComponents, medication: medication)
              notifications.append(notification)
            }
          }
        }
      }
    }
    return notifications
  }
}

public struct Notification {
  var id: String {
    return "\(title)-\(datetime)"
  }
  var title: String
  var datetime: DateComponents
  var medication: Medication
}

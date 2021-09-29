//
//  Notifications.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/28/21.
//

import Foundation
import UserNotifications
import SwiftUI


struct Notifications: View {
    @Binding var permissionGranted: Bool
    @Binding var showNotificationPermissions: Bool
    @Binding var showAddReminderView: Bool
    var body: some View {
        VStack {
            Button("Request Permission") {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                        permissionGranted = true
                        showNotificationPermissions = false
                        showAddReminderView = false
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }

            Button("Schedule Notification") {
                let content = UNMutableNotificationContent()
                content.title = "Feed the cat"
                content.subtitle = "It looks hungry"
                content.sound = UNNotificationSound.default

                // show this notification five seconds from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                // choose a random identifier
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                // add our notification request
                UNUserNotificationCenter.current().add(request)
            }
        }
        
    }
}

struct Notifications_Previews: PreviewProvider {

    static var previews: some View {
        Notifications(permissionGranted: .constant(false), showNotificationPermissions: .constant(true), showAddReminderView: .constant(false))
    }
}

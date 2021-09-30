//
//  MedsMinderApp.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/1/21.
//

import SwiftUI

@main
struct MedsMinderApp: App {
    @ObservedObject var data = MedData()
    @State var permissionGranted: Bool = false
    @ObservedObject var notificationsBuilder = LocalNotificationManager()


    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainView(meds: $data.meds, permissionGranted: $permissionGranted) {
                    data.save()
                }
                .navigationBarHidden(true)
            }
            .onAppear {
                data.load()
                self.checkPermissions()
                notificationsBuilder.scheduleNotifications(data: data.meds)
            }
        }
    }
    
    func checkPermissions() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                  (settings.authorizationStatus == .provisional) else { return }

            if settings.alertSetting == .enabled {
                permissionGranted = true
            } else {
                permissionGranted = false
            }
        }
    }
    

    
    
}

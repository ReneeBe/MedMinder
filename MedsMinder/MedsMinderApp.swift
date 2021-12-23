//
//  MedsMinderApp.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/1/21.
//

import SwiftUI
import CloudKit
import UIKit
import UserNotifications

@main
struct MedsMinderApp: App {
    @ObservedObject var localData = MedData()
    @State var permissionGranted: Bool = false
    @ObservedObject var notificationsBuilder = LocalNotificationManager()
//  @ObservedObject var data = ViewModel()
    @StateObject var data = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(meds: $localData.meds, permissionGranted: $permissionGranted) {
                //inside here is the save action for the whole app -- which is called when the app window is exited
                    localData.meds = data.medData
                    localData.save()
                }
                .environmentObject(data)
            .onAppear {
                localData.load()
                self.checkPermissions()
                notificationsBuilder.scheduleNotifications(reminderData: data.reminderData, medData: data.medData)
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

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

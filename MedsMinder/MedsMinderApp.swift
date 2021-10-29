//
//  MedsMinderApp.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/1/21.
//

import SwiftUI
import CloudKit
import UIKit


@main
struct MedsMinderApp: App {
    @ObservedObject var localData = MedData()
//    @ObservedObject var data = ViewModel()
    @State var permissionGranted: Bool = false
    @ObservedObject var notificationsBuilder = LocalNotificationManager()
    @StateObject var data = ViewModel()
//    @State var showAllReminders: Bool = true
//    @State var showAllMedications: Bool = false

    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(permissionGranted: $permissionGranted).environmentObject(data)
//                MedicationsView(permissionGranted: $permissionGranted).environmentObject(MedsMinderApp.data)
//                MainView(meds: $data.medData, permissionGranted: $permissionGranted
//                ).environmentObject(MedsMinderApp.data)
//                {
//                    data.saveRecord(meds: data.medData)
//                    print("saved! \(data.medData)")
//                    localData.save()
//                }
//                    .navigationBarItems(
//                        leading: Button(action: {
//                            showAllReminders = true
//                            showAllMedications = false
//                        }, label: {
//                            Text("Reminders")
//                        }),
//                        trailing: Button(action: {
//                            showAllMedications = true
//                            showAllReminders = false
//                        }, label: {
//                            Text("Medications")
//
//                        })
//                    )
                .navigationBarHidden(true)
            }
            .onAppear {
                data.getAllData()
//                data.getData()
                print("getting data from the cloud:")
                print(data.medData)
                localData.load()
                self.checkPermissions()
                notificationsBuilder.scheduleNotifications(data: data.medData)
            }
//            .onAppear {
//                MedsMinderApp.data.getData()
//                print("getting data from the cloud:")
//                print(MedsMinderApp.data.medData)
//                localData.load()
//                self.checkPermissions()
//                notificationsBuilder.scheduleNotifications(data: MedsMinderApp.data.medData)
//            }
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

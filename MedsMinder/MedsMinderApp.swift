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
//    @ObservedObject var data = ViewModel()
    @State var permissionGranted: Bool = false
    @ObservedObject var notificationsBuilder = LocalNotificationManager()
    @StateObject var data = ViewModel()
//    @State var showAllReminders: Bool = true
//    @State var showAllMedications: Bool = false

    
    var body: some Scene {
        WindowGroup {
//            NavigationView {
            ContentView(meds: $localData.meds, permissionGranted: $permissionGranted) {
                    print("RENEE we are in the save action of medsminderapp")
//                    data.updateAndSave(meds: data.medData)
                    print("saved! \(data.medData)")
                    localData.meds = data.medData                
                    localData.save()

                }
                .environmentObject(data)
//                ContentView().environmentObject(data)

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
//                .navigationBarHidden(true)
//            }
            .onAppear {
//                data.init()
//                data.getMedData()
//                data.getReminderData()
//                data.getData()
//                print(data.medData)
//                print(data.reminderData)
                print("renee we are in onappear in medsminderapp")
                localData.load()
                self.checkPermissions()
                print("renee we disabled notifications builder but you cant delete anything else until you get it back its the next line below right here:")
                notificationsBuilder.scheduleNotifications(reminderData: data.reminderData, medData: data.medData)
//                print("localData from medsminderapp: \(localData)")

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

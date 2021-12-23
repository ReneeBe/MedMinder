//
//  ContentView.swift
//  MedsMinder
//
//  Created by Renee Berger on 10/25/21.
//

import SwiftUI
import UserNotifications
import CloudKit


struct ContentView: View {
    @EnvironmentObject var data: ViewModel
    @Binding var meds: [Med]
    @ObservedObject var notificationsBuilder = LocalNotificationManager()
    @Environment(\.scenePhase) private var scenePhase
    @Binding var permissionGranted: Bool
    public let saveAction: () -> Void
    
    var body: some View {
        TabView {
            RemindersView(meds: $meds, permissionGranted: $permissionGranted)
                .tabItem {
                    Label("Reminders", systemImage: "clock.fill").font(.title)
                }
            MedicationsView(permissionGranted: $permissionGranted)
                .tabItem {
                    Label("Medications", systemImage: "pills.circle.fill").font(.largeTitle)
                }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .inactive {
                saveAction()
            }
            notificationsBuilder.scheduleNotifications(reminderData: data.reminderData, medData: data.medData)
        }
        .onAppear {
            data.getMedData() { _ in}
            data.getReminderData() {_ in}
            notificationsBuilder.requestAuthorization(reminderData: data.reminderData, medData: data.medData)
            notificationsBuilder.scheduleNotifications(reminderData: data.reminderData, medData: data.medData)
        }
        .environmentObject(data)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(meds: .constant(MedData().meds), permissionGranted: .constant(true), saveAction: {})
    }
}

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
//    @State var showAllMedications: Bool = false
//    @State var showAllReminders: Bool = true
    @State private var showNewMedPopover = false
    @State private var showAddReminderView = false
    @State private var newMedData = Med.Data(format: "tablet")
    @State private var color: Color = Color(.systemYellow)
    @State private var showDeleteButton = false
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
//        .font(.headline)
        
//        NavigationView {
//            ZStack {
//                Color(.systemBlue).opacity(0.06).ignoresSafeArea()
////                RemindersView(permissionGranted: $permissionGranted)
//                if showAllReminders == true {
//                    RemindersView(permissionGranted: $permissionGranted)
//                } else {
//                    MedicationsView(permissionGranted: $permissionGranted)
//                }
//
//            }
//            .navigationBarTitle(showAllReminders ? "Reminders" : "All Medications")
//            .navigationBarTitleDisplayMode(.large)
//            .navigationBarItems(
//                leading: Button(action: {
//                    showAllReminders.toggle()
//                    showAllMedications.toggle()
//                }, label: {
//                    if showAllReminders == false {
//                        Text("Reminders")
//                    } else {
//                        Text("Medications")
//                    }
//                }),
//                trailing: Button(action: {
//                    print("pushed the add button")
//                }, label: {
//                    if showAllMedications == true {
//                        Image(systemName: "plus").accessibilityLabel(Text("Add Medication"))
//
//
//                    } else if showAllReminders == true {
//                        Image(systemName: "plus").accessibilityLabel(Text("Add Reminder"))
//                    }
//                })
//            )
            .onChange(of: scenePhase) { phase in
                if phase == .inactive {
                    print("hello")
                    saveAction()
                }
                print("we are in the else of of the onchange in contentview!")
                
                notificationsBuilder.scheduleNotifications(reminderData: data.reminderData, medData: data.medData)
//                doSubmission(med: Med)
            }
            .onAppear {
//                data.init()
//                data.getAllData()
                data.getMedData()
                data.getReminderData()
                print("localData from ContentView: \(meds)")
                print("data from web: \(data.medData)")
                notificationsBuilder.requestAuthorization(reminderData: data.reminderData, medData: data.medData)
                notificationsBuilder.scheduleNotifications(reminderData: data.reminderData, medData: data.medData)
//                meds.getData()
//                doSubmission()

            }
            .environmentObject(data)
//        }
//            .environmentObject(data)
    }
    
//    private func deleteMeds(at offsets: IndexSet) {
//        guard let firstIndex = offsets.first else {
//            return
//        }
//
//        let medName = data.medData[firstIndex].name
//        data.deleteMeds(name: medName) { _ in }
//    }
    
//    func createReminder(med: Med, reminder: Reminder, name: String) {
//        data.getLastReminderOrCallCreateReminder(med: med, reminder: reminder, name: name)
//    }
    

//    func deleteMeds(at offsets: IndexSet) {
//        guard let firstIndex = offsets.first else {
//            return
//        }
//
//        let medName = data.medData[firstIndex].name
//        print("we are in deleteMeds in mainview, here is medName aka the one youre trying to delete: \(medName)")
//        data.deleteMeds(name: medName) { _ in }
//    }
        
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(meds: .constant(MedData().meds), permissionGranted: .constant(true), saveAction: {})
    }
}

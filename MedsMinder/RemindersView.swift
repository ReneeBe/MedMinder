//
//  RemindersView.swift
//  MedsMinder
//
//  Created by Renee Berger on 10/25/21.
//

import SwiftUI
import UserNotifications
import CloudKit

struct RemindersView: View {
    @EnvironmentObject var data: ViewModel
    //    @Binding var meds: [Med]
    @ObservedObject var notificationsBuilder = LocalNotificationManager()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showNewMedPopover = false
    @State private var showAddReminderView = false
    @Binding var permissionGranted: Bool
    @State private var newMedData = Med.Data(format: "tablet")
    @State private var color: Color = Color(.systemYellow)
    @State private var showDeleteButton = false

    //    public let saveAction: () -> Void
    
    var body: some View {
//        NavigationView {
//            ZStack {
//                Color(.systemBlue).opacity(0.06).ignoresSafeArea()
                List{
//                    HStack (alignment: .top) {
//                        Image(systemName: "timer")
//                        Text("Scheduled")
//                        Spacer()
//                    }
//                    .font(.headline)
//                    .padding(.leading)
//                    .padding(.top)
    //                    Divider()
                    ForEach(0..<data.reminderData.count, id: \.self) { i in
//                        if data.reminderData[i].scheduled! {
                        ReminderRowView(showAddReminderView: showAddReminderView, permissionGranted: $permissionGranted, reminder: self.$data.reminderData[i])
                    }
//                    }.onDelete(perform: deleteMeds)
//
//                    HStack (alignment: .top){
//                        Text("On Demand")
//                        Spacer()
//                    }
//                    .font(.headline)
//                    .padding(.leading)
//                    .padding(.top)
//    //                    Divider()
//                    ForEach(0..<data.medData.count, id: \.self) { i in
//                        if data.medData[i].scheduled! == false {
//                            RowView(showAddReminderView: showAddReminderView, permissionGranted: $permissionGranted, med: self.$data.medData[i])
//                        }
//                    }
//                    .onDelete(perform: self.deleteMeds)
                }
                .listRowBackground(Color(.systemBlue).opacity(0.06))
                .foregroundColor(Color(.darkGray))
                .listStyle(InsetListStyle())
    //                .padding(15)
//            }
//            .navigationBarTitle("Reminder")
//            .navigationBarTitleDisplayMode(.large)
//            .navigationBarItems(
//                leading:
//                    Button( action: {
//                        showDeleteButton.toggle()
//                    }) {
//                        if showDeleteButton {
//                            Text("Done")
//                        } else {
//                            Text("Edit")
//                        }
//                    },
//
//    //                EditButton(),
//                trailing:
//                    Button(action: {
//                            showNewMedPopover.toggle()
//                    }) {
//                        Image(systemName: "plus")
//                    }
//                    .sheet(isPresented: $showNewMedPopover) {
//                        NavigationView {
//                            NewMedicationView(medData: $newMedData, color: $color)
//                                .navigationBarTitle("New Medication", displayMode: .inline)
//                                .navigationBarItems(
//                                    leading:
//                                        Button(action: {
//                                            showNewMedPopover.toggle()
//                                            print("hello from mainview! \(data.medData)")
//
//                                        }, label: {
//                                            Text("Close")
//                                        })
//                                    , trailing:
//                                        Button("Add") {
//                                            let newMed = Med(name: newMedData.name, details: "Every Evening", format: newMedData.format, color: color, shape: newMedData.shape, engraving: newMedData.engraving, dosage: Double(1), scheduled: false, reminders: [], history: [])
//                                            data.medData.append(newMed)
//                                            print("we added to meds!: \(data.medData)")
//                                            data.saveRecord(meds: [newMed])
//    //                                            saveAction()
//    //                                            meds.saveRecord(newMed)
//    //                                            doSubmission(med: newMed)
//                                            showNewMedPopover.toggle()
//                                        })
//                        }
//                }
//            )
//            .navigationBarBackButtonHidden(true)
//            .onChange(of: scenePhase) { phase in
//                if phase == .inactive {
//                    print("hello")
//    //                    saveAction()
//                }
//                notificationsBuilder.scheduleNotifications(data: data.medData)
//    //                doSubmission(med: Med)
//            }
//            .onAppear {
//                notificationsBuilder.scheduleNotifications(data: data.medData)
//    //                meds.getData()
//    //                doSubmission()
//
//            }
//        }
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


    func deleteMeds(at offsets: IndexSet) {
        guard let firstIndex = offsets.first else {
            return
        }
        
        let medName = data.medData[firstIndex].name
        print("we are in deleteMeds in mainview, here is medName aka the one youre trying to delete: \(medName)")
        data.deleteMeds(name: medName) { _ in }
    }
}

struct RemindersView_Previews: PreviewProvider {
    static var previews: some View {
        RemindersView(permissionGranted: .constant(true))
    }
}



//
//struct MainView: View {
//    @EnvironmentObject var data: ViewModel
////    @Binding var meds: [Med]
//    @ObservedObject var notificationsBuilder = LocalNotificationManager()
//    @Environment(\.scenePhase) private var scenePhase
//    @State private var showNewMedPopover = false
//    @State private var showAddReminderView = false
//    @Binding var permissionGranted: Bool
//    @State private var newMedData = Med.Data(format: "tablet")
//    @State private var color: Color = Color(.systemYellow)
////    public let saveAction: () -> Void
//
//
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Color(.systemBlue).opacity(0.06).ignoresSafeArea()
//                ScrollView {
//                    HStack (alignment: .top) {
//                        Image(systemName: "timer")
//                        Text("Scheduled")
//                        Spacer()
//                    }
//                    .font(.headline)
//                    .padding(.leading)
//                    .padding(.top)
//                    Divider()
//                    ForEach(0..<meds.count, id: \.self) { i in
//                        if meds[i].scheduled! {
//                            RowView(showAddReminderView: showAddReminderView, permissionGranted: $permissionGranted, med: self.$meds[i])
//                        }
//                    }
//                    HStack (alignment: .top){
//                        Text("On Demand")
//                        Spacer()
//                    }
//                    .font(.headline)
//                    .padding(.leading)
//                    .padding(.top)
//                    Divider()
//                    ForEach(0..<meds.count, id: \.self) {i in
//                        if meds[i].scheduled! == false {
//                            RowView(showAddReminderView: showAddReminderView, permissionGranted: $permissionGranted, med: self.$meds[i])
//                        }
//                    }
//                }
//                .padding(15)
//                .foregroundColor(Color(.darkGray))
//            }
//            .navigationBarTitle("Reminder")
//            .navigationBarItems(
//                leading:
//                    EditButton(),
//                trailing:
//                    Button(action: {
//                            showNewMedPopover.toggle()
//                    }) {
//                        Image(systemName: "plus")
//                    }
//                    .sheet(isPresented: $showNewMedPopover) {
//                        NavigationView {
//                            NewMedicationView(medData: $newMedData, color: $color)
//                                .navigationBarTitle("New Medication", displayMode: .inline)
//                                .navigationBarItems(
//                                    leading:
//                                        Button(action: {
//                                            showNewMedPopover.toggle()
//                                            print("hello from mainview! \(meds)")
//
//                                        }, label: {
//                                            Text("Close")
//                                        })
//                                    , trailing:
//                                        Button("Add") {
//                                            let newMed = Med(name: newMedData.name, details: "Every Evening", format: newMedData.format, color: color, shape: newMedData.shape, engraving: newMedData.engraving, dosage: Double(1), scheduled: false, reminders: [], history: [])
//                                            meds.append(newMed)
//                                            print("we added to meds!: \(meds)")
//                                            meds.save(record: newMed)
////                                            saveAction()
////                                            meds.saveRecord(newMed)
////                                            doSubmission(med: newMed)
//                                            showNewMedPopover.toggle()
//                                        })
//                        }
//                        .onDisappear{
//                            newMedData = Med.Data(format: "tablet")
//                        }
//                }
//            )
//            .navigationBarBackButtonHidden(true)
//            .onChange(of: scenePhase) { phase in
//                if phase == .inactive {
//                    saveAction()
//                }
//                notificationsBuilder.scheduleNotifications(data: meds)
////                doSubmission(med: Med)
//            }
//            .onAppear {
//                notificationsBuilder.scheduleNotifications(data: meds)
////                meds.getData()
////                doSubmission()
//
//            }
//        }
//    }
//
//
////    func doSubmission(med: Med) {
////        let container = CKContainer.default()
////        let database = container.privateCloudDatabase
////        let medRecord = CKRecord(recordType: "Med")
////
////        medRecord.setValuesForKeys([
//////            "id": med.id,
////            "name": med.name,
////            "details": med.details,
////            "format": med.format,
//////            "color": med.color!,
////            "shape": med.shape,
////            "engraving": med.engraving,
////            "dosage": med.dosage,
////            "scheduled": med.scheduled!,
//////            "reminders": med.reminders,
//////            "history": med.history
////        ])
////
////
////        CKContainer.default().accountStatus { accountStatus, error in
////            if accountStatus == .noAccount {
////                DispatchQueue.main.async {
////                    let message =
////                        """
////                        Sign in to your iCloud account to write records.
////                        On the Home screen, launch Settings, tap Sign in to your
////                        iPhone/iPad, and enter your Apple ID. Turn iCloud Drive on.
////                        """
////                    let alert = UIAlertController(
////                        title: "Sign in to iCloud",
////                        message: message,
////                        preferredStyle: .alert)
////                    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
//////                    self.present(alert, animated: true)
////                }
////            }
////            else {
////                let saveOperation = CKModifyRecordsOperation(recordsToSave: [medRecord])
////                saveOperation.savePolicy = .allKeys
////
////                saveOperation.modifyRecordsCompletionBlock = { records, _, error in
////
////                    if let error = error {
//////                        completionHandler(.failure(error))
////                        debugPrint("Error saving new contact: \(error)")
////                    } else {
////                        DispatchQueue.main.async {
////                            records?.forEach { record in
////                                if let name = record["name"] as? String {
////                                    meds[record.name] = name
////                                }
////                            }
////                            self.saveLocalCache()
//////                            completionHandler(.success(()))
////                        }
////                    }
////                }
////
////                database.add(medRecord)
////
//////                { medRecord, error in
//////                    if let error = error {
//////                        print("error: \(error)")
//////                        return
//////                    }
//////                }
////            }
////        }
////
////    }
//
//
//
//
////    private func binding(for med: Med) -> Binding<Med> {
////        guard let medIndex = meds.firstIndex(where: { $0.id == med.id }) else {
////            fatalError("Can't find med in array")
////        }
////        return $meds[medIndex]
////    }
//}
//
//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView(meds: .constant(Med.data), permissionGranted: .constant(false), saveAction: {})
//    }
//}


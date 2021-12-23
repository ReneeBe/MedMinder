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
    @Binding var meds: [Med]
    @ObservedObject var notificationsBuilder = LocalNotificationManager()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showNewMedPopover = false
    @State private var showAddReminderView = false
    @Binding var permissionGranted: Bool
    @State private var newMedData = Med.Data(format: "tablet")
    @State private var color: Color = Color(.systemYellow)

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBlue).opacity(0.06).ignoresSafeArea()
                List{
                    ForEach(0..<data.reminderData.count, id: \.self) { i in
                        let med: Med = findMed(reminder: self.data.reminderData[i])
                        ReminderRowView(showAddReminderView: showAddReminderView, permissionGranted: $permissionGranted, reminder: self.$data.reminderData[i], med: med)
                    }
                    .onDelete(perform: self.deleteReminder)
                }
                .listRowBackground(Color(.systemBlue).opacity(0.06))
                .foregroundColor(Color(.darkGray))
                .listStyle(InsetListStyle())
            }
            .navigationBarTitle("Reminders", displayMode: .inline)
        }
            .onChange(of: scenePhase) { phase in
                if phase == .inactive {
                    data.getReminderData(){_ in}
                    data.getMedData() {_ in}
                } else {
                    data.getReminderData(){_ in}
                    data.getMedData(){_ in}
                }
            }
            .onAppear {
                    data.getMedData(){_ in}
                    data.getReminderData(){_ in}
            }
        }

    func deleteReminder(at offsets: IndexSet) {
        guard let firstIndex = offsets.first else {
            return
        }
        let reminder = data.reminderData[firstIndex]
        let med = findMed(reminder: reminder)
        data.findMedForRecID(med: med, reminders: [reminder], history: nil, process: "deleteReminder") { _ in }
        data.reminderData.remove(at: firstIndex)
    }


    func findMed(reminder: Reminder) ->  Med {
        var currentMed: Med = Med.data[0]
        if let foundMed = data.medData.first(where: {$0.name == reminder.medName}) {
            currentMed = foundMed
        }
        return currentMed
    }
}

struct RemindersView_Previews: PreviewProvider {
    static var previews: some View {
        RemindersView(meds: .constant(MedData().meds), permissionGranted: .constant(true))
    }
}

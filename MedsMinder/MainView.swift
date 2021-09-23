//
//  ContentView.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/1/21.
//

import SwiftUI

struct MainView: View {
    @Binding var meds: [Med]
    @Environment(\.scenePhase) private var scenePhase
    @State private var showNewMedPopover = false
    @State private var showAddReminderView = false
    @State private var newMedData = Med.Data(format: "tablet")
    @State private var color: Color = Color(.systemYellow)
    public let saveAction: () -> Void
    var progressValue: Double = 270
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBlue).opacity(0.06).ignoresSafeArea()
                VStack {
                    HStack (alignment: .top){
                        Image(systemName: "timer")
                        Text("Scheduled")
                        Spacer()
                    }
                    .font(.headline)
                    .padding(.leading)
                    .padding(.top)
                    Divider()
                    ScrollView {
                        VStack(alignment: .center, spacing: 5) {
                            ForEach(meds) { med in
                                if med.frequencyInMinutes > 0 {
                                    RowView(showAddReminderView: showAddReminderView, med: med, keyword: "scheduled", progress: progressValue)
                                }
//                                if med.frequencyInMinutes > 0 {
//                                    RowView(showAddReminderView: showAddReminderView, med: med, keyword: "scheduled", progress: progressValue)
//                                }
                            }
                        }
                    }
                    HStack (alignment: .top){
                        Text("On Demand")
                        Spacer()
                    }
                    .padding(.leading)
                    .font(.headline)
                    
                    Divider()
                    
                    ScrollView {
                        ForEach(meds) {med in
                            if med.frequencyInMinutes == 0 {
                                RowView(showAddReminderView: showAddReminderView, med: med, keyword: "demand", progress: progressValue)
                            }
                        }
                    }
                    .padding(15)
                }
                .foregroundColor(Color(.darkGray))
            }
            .navigationBarTitle("Reminder")
            .navigationBarItems(
                leading:
                    EditButton(),
                trailing:
                    Button(action: {
                            showNewMedPopover.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $showNewMedPopover) {
                        NavigationView {
                            NewMedicationView(medData: $newMedData, color: $color)
                                .navigationBarTitle("New Medication", displayMode: .inline)
                                .navigationBarItems(
                                    leading:
                                        Button(action: {
                                            showNewMedPopover.toggle()
                                        }, label: {
                                            Text("Close")
                                        })
                                    , trailing:
                                        Button("Add") {
//                                            let newMed = Med(name: newMedData.name, details: "Every Evening", format: newMedData.format, color: color, shape: newMedData.shape, engraving: newMedData.engraving, dosage: Double(1), frequencyInMinutes: Int(180), reminders: [])
                                            let newMed = Med(name: newMedData.name, details: "Every Evening", format: newMedData.format, color: color, shape: newMedData.shape, engraving: newMedData.engraving, dosage: Double(1), frequencyInMinutes: Int(180), reminders: [], showAsScheduled: false)
                                            meds.append(newMed)
                                            showNewMedPopover.toggle()
                                })
                        }
                    }
            )
            .navigationBarBackButtonHidden(true)
            .onChange(of: scenePhase) { phase in
                if phase == .inactive { saveAction() }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(meds: .constant(Med.data), saveAction: {})
    }
}


//        private func binding(for med: Med) -> Binding<Med> {
//            guard let medIndex = meds.firstIndex(where: { $0.id == med.id }) else {
//                fatalError("Can't find med in array")
//            }
//            return $meds[medIndex]
//        }

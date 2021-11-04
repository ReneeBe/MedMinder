//
//  MedicationsView.swift
//  MedsMinder
//
//  Created by Renee Berger on 10/22/21.
//

import SwiftUI
import UserNotifications
import CloudKit

struct MedicationsView: View {
    @EnvironmentObject var data: ViewModel
    @Binding var permissionGranted: Bool
    @State private var showNewMedPopover = false
    @State private var showAddReminderView = false
    @State private var newMedData = Med.Data(format: "tablet")
    @State private var color: Color = Color(.systemYellow)
    @State private var showDeleteButton = false
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBlue).opacity(0.06).ignoresSafeArea()
                List{
                    HStack (alignment: .top) {
                        Image(systemName: "timer")
                        Text("Scheduled")
                        Spacer()
                    }
                    .font(.headline)
                    .padding(.leading)
                    .padding(.top)
    //                    Divider()
                    ForEach(0..<data.medData.count, id: \.self) { i in
                        if data.medData[i].scheduled! {
                            RowView(showAddReminderView: showAddReminderView, permissionGranted: $permissionGranted, med: self.$data.medData[i])
                        }
                    }
                    
                    HStack (alignment: .top){
                        Text("On Demand")
                        Spacer()
                    }
                    .font(.headline)
                    .padding(.leading)
                    .padding(.top)
    //                    Divider()
                    ForEach(0..<data.medData.count, id: \.self) { i in
                        if data.medData[i].scheduled! == false {
                            RowView(showAddReminderView: showAddReminderView, permissionGranted: $permissionGranted, med: self.$data.medData[i])
                        }
                    }
//                    .onDelete(perform: self.deleteMeds)
                }
                .listRowBackground(Color(.systemBlue).opacity(0.06))
                .foregroundColor(Color(.darkGray))
                .listStyle(InsetListStyle())
    //                .padding(15)
            }
            .navigationBarTitle("Medications", displayMode: .inline)
            .navigationBarItems(trailing:
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
                                        let newMed = Med(name: newMedData.name, details: "Every Evening", format: newMedData.format, color: color, shape: newMedData.shape, engraving: newMedData.engraving, dosage: Double(1), scheduled: false, reminders: [], history: [])
                                        data.medData.append(newMed)
                                        print("we added to meds!: \(data.medData)")
                                        data.saveRecord(meds: [newMed])
//                                            saveAction()
//                                            meds.saveRecord(newMed)
//                                            doSubmission(med: newMed)
                                        showNewMedPopover.toggle()
                                    })
                    }
            }
//                )
                .navigationBarBackButtonHidden(true)
//                .onChange(of: scenePhase) { phase in
//                    if phase == .inactive {
//                        print("hello")
//    //                    saveAction()
//                    }
//                    notificationsBuilder.scheduleNotifications(reminderData: data.reminderData, medData: data.medData)
//    //                doSubmission(med: Med)
//                }

            )
        }
        
    }
}

struct MedicationsView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationsView(permissionGranted: .constant(false))
    }
}

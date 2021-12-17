//
//  MedicationsView.swift
//  MedsMinder
//
//  Created by Renee Berger on 10/22/21.
//

import SwiftUI
import UserNotifications
import CloudKit
//import UIKit

struct MedicationsView: View {
    @EnvironmentObject var data: ViewModel
    @Binding var permissionGranted: Bool
    @State private var showNewMedPopover = false
    @State private var showAddReminderView = false
    @State private var newMedData = Med.Data(format: "tablet")
    @State private var color: [Color] = [Color(.blue), Color(.white)]
    @State private var showDeleteButton = false
    @Environment(\.scenePhase) private var scenePhase
//    @State private var addMedState =
    
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
                    .onDelete(perform: self.deleteMeds)

                    
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
                    .onDelete(perform: self.deleteMeds)
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
                .sheet(isPresented: $showNewMedPopover, onDismiss: didDismissCreateNewMed) {
                    NavigationView {
                        NewMedicationView(medData: $newMedData, color: $color)
                            .navigationBarTitle("New Medication", displayMode: .inline)
                            .navigationBarItems(
                                leading:
                                    Button("Dismiss", action: {
                                        showNewMedPopover.toggle()
                                    })
                                , trailing:
                                    Button("Add") {
//                                        if newMedData.format == "liquid" {
//                                            newMedData.shape = ["drop.fill"]
//                                            newMedData.engraving = ""
//                                        } else if newMedData.format == "capsule" {
//                                            newMedData.shape = ["capsule.lefthalf.filled"]
//                                        }
                                        let newMed = Med(name: newMedData.name, details: "Every Evening", format: newMedData.format, color: color, shape: newMedData.shape, engraving: newMedData.engraving , dosage: Double(1), scheduled: false, reminders: [], history: [])
                                        data.medData.append(newMed)
                                        print("we added to meds!: \(data.medData)")
                                        data.saveRecord(meds: [newMed])
//                                        data.getMedData()
//                                        data.getMedData()
//                                            saveAction()
//                                            meds.saveRecord(newMed)
//                                            doSubmission(med: newMed)
                                        showNewMedPopover.toggle()
                                    })
                    }
            }
//                )
                .navigationBarBackButtonHidden(true)
//                .onChange(of: data) {  in
//
//                }
                .onChange(of: scenePhase) { phase in
                    if phase == .inactive {
                        print("hello from medicationsView")
    //                    saveAction()
                    }
                    print("we are in the onchange in medicationsview!!!")
                    data.getMedData() {_ in}
                    data.getReminderData() {_ in}
//                    notificationsBuilder.scheduleNotifications(reminderData: data.reminderData, medData: data.medData)
    //                doSubmission(med: Med)
                }
                .onAppear{
                    print("RENEE we are in the medicationsview onappear")
                    data.getMedData() {_ in}
                    data.getReminderData(){_ in}
                }

                                

            )
        }
        
    }
    
    func didDismissCreateNewMed() {
        print("doing the things for when you dismiss a sheet")
//        Task {
//            do {
//            } catch {
//                print("error in dismissing create new med")
//                
//            }
//            
//        }
        
        data.getMedData() {_ in}
        data.getReminderData(){_ in}
    }
    
    func deleteMeds(at offsets: IndexSet) {
        guard let firstIndex = offsets.first else {
            return
        }
        let med = data.medData[firstIndex]
        let medName = data.medData[firstIndex].name
        print("we are in deleteMeds in medicationsView, here is medName aka the one youre trying to delete: \(medName)")
        data.findMedForRecID(med: med, reminders: nil, history: nil, process: "deleteMed") { _ in }
        data.medData.remove(at: firstIndex)
        data.reminderData.removeAll {$0.medName == medName}
    }
    
}

struct MedicationsView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationsView(permissionGranted: .constant(false))
    }
}

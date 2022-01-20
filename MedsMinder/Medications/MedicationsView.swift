//
//  MedicationsView.swift
//  MedsMinder
//
//  Created by Renee Berger on 10/22/21.
//

import CloudKit
import SwiftUI
import UserNotifications
import os.log

struct MedicationsView: View {
  @EnvironmentObject var eventHandler: EventHandler
  //MARK: added the line below to enable pull to refresh
  @EnvironmentObject var model: Model
  var viewModel: ViewModel
  @State private var showNewMedPopover = false
  @State private var showAddReminderView = false
  @State private var newMedicationData = Medication.Data(format: .tablet)
  @State private var color: [Color] = [Color(.blue), Color(.blue)]
  @Environment(\.scenePhase) private var scenePhase

  var body: some View {
    NavigationView {
      // TODO: Pull this out into a list view class?
      if viewModel.medications.count == 0 {
        Text("No medications\n You can add medications by tapping the \"+\" icon above")
          .multilineTextAlignment(.center)
          .padding().padding().font(.title).foregroundColor(.secondary)
      } else {
        List {
          Section(header: Text("Scheduled \(Image(systemName: "timer"))")) {
            ForEach(viewModel.scheduledMedications) { medication in
              RowView(
                showAddReminderView: showAddReminderView,
                medication: medication, viewModel: viewModel)
            }
            .onDelete(perform: { offsets in
              let medicationsToDelete = offsets.map { viewModel.scheduledMedications[$0] }
              eventHandler.deleteMedications(medications: medicationsToDelete)
            })
          }
          Section(header: Text("On Demand")) {
            ForEach(viewModel.onDemandMedications) { medication in
              RowView(
                showAddReminderView: showAddReminderView,
                medication: medication, viewModel: viewModel)
            }
            .onDelete(perform: { offsets in
              let medicationsToDelete = offsets.map { viewModel.onDemandMedications[$0] }
              eventHandler.deleteMedications(medications: medicationsToDelete)
            })
          }
        }
        .listRowBackground(Color(.systemBlue).opacity(0.06))
        .foregroundColor(.primary)
        .listStyle(InsetListStyle())
        .navigationBarTitle("Medications", displayMode: .automatic)
        .navigationBarItems(
        trailing:
          Button(action: {
            showNewMedPopover.toggle()
          }) {
            Image(systemName: "plus")
          }
          .sheet(isPresented: $showNewMedPopover) {
            // TODO: Can this be factored into another view somehow?
            NavigationView {
              NewMedicationView(medData: $newMedicationData, color: $color)
                .navigationBarTitle("New Medication", displayMode: .inline)
                .navigationBarItems(
                  leading:
                    Button(
                      "Dismiss",
                      action: {
                        showNewMedPopover.toggle()
                      }),
                  trailing:
                    // TODO: Disable this when there is no med name
                    Button("Add") {
                      var newMedication = Medication(
                        name: newMedicationData.name, details: "Every Evening",
                        format: newMedicationData.format,
                        color: color, shape: newMedicationData.shape,
                        engraving: newMedicationData.engraving,
                        dosage: Double(1), reminders: [],
                        history: [])
                      switch newMedication.format {
                      case .liquid:
                        newMedication.shape = ["drop.fill"]
                      case .capsule:
                        newMedication.shape = ["capsule.lefthalf.filled"]
                      case .tablet: break
                      }

                      if newMedication.format != .capsule {
                        newMedication.color[1] = newMedication.color[0]
                      }
                      eventHandler.createMedication(medication: newMedication)
                      showNewMedPopover.toggle()
                    }
                    .disabled(newMedicationData.name == "")
                )
            }.onDisappear(perform: {
              newMedicationData = Medication.Data()
            })
          }
          .navigationBarBackButtonHidden(true)
        )
//        //MARK: PULL-TO-REFRESH ENABLED HERE
//        .refreshable {
//          do {
//            print("hello its a refresh here!")
//            try await model.startSync()
//          } catch let error {
//            print("error with refresh: \(error)")
//          }
//        } 
      }
    }
  }
}

struct MedicationsView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      MedicationsView(viewModel: ViewModel.data)
        .environmentObject(EventHandler(model: PreviewModel()))
      MedicationsView(viewModel: ViewModel())
        .environmentObject(EventHandler(model: PreviewModel()))
    }
  }
}

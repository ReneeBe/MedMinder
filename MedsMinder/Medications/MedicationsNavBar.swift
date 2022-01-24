//
//  MedicationsNavBar.swift
//  MedsMinder
//
//  Created by Renee Berger on 1/24/22.
//

import SwiftUI

struct MedicationsNavBar: View {
  @EnvironmentObject var eventHandler: EventHandler
  var viewModel: ViewModel
  @State private var showNewMedPopover = false
  @State private var showAddReminderView = false
  @State private var newMedicationData = Medication.Data(format: .tablet)
  @State private var color: [Color] = [Color(.blue), Color(.blue)]
  @Environment(\.scenePhase) private var scenePhase

  var body: some View {
    NavigationView {
      MedicationsView(viewModel: viewModel)
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
    }
  }
}

struct MedicationsNavBar_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      MedicationsNavBar(viewModel: ViewModel.data)
        .environmentObject(EventHandler(model: PreviewModel()))
      MedicationsNavBar(viewModel: ViewModel.data)
        .environmentObject(EventHandler(model: PreviewModel()))
      MedicationsNavBar(viewModel: ViewModel.data)
        .environmentObject(EventHandler(model: PreviewModel()))
      MedicationsNavBar(viewModel: ViewModel.data)
        .environmentObject(EventHandler(model: PreviewModel()))
    }
  }
}

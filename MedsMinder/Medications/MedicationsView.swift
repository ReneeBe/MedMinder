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
  var viewModel: ViewModel
  @State private var showNewMedPopover = false
  @State private var showAddReminderView = false
  @State private var newMedicationData = Medication.Data(format: .tablet)
  @State private var color: [Color] = [Color(.blue), Color(.blue)]
  @Environment(\.scenePhase) private var scenePhase

  var body: some View {
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

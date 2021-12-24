//
//  PreviewModel.swift
//  MedsMinder
//
//  Created by Renee Berger on 12/30/21.
//

import Foundation

// A version of the model that doesn't rely on CloudKit, intended to be used in previews or in local
// debug builds. It does not persist to disk but is otherwise fully functional.
@MainActor class PreviewModel: Model {
  override init() {
    super.init()
    viewModel = ViewModel(
      medications: Medication.data, reminders: Reminder.data, history: History.data)
  }

  override func startSync() async throws {
    LocalNotificationManager.sharedNotificationManager.schedule(viewModel: viewModel)
  }

  override func add(medication: Medication) {
    viewModel.medications.append(medication)
  }

  override func add(reminder: Reminder) {
    viewModel.reminders.append(reminder)
    LocalNotificationManager.sharedNotificationManager.schedule(viewModel: viewModel)
  }

  override func add(history: History) {
    viewModel.history.append(history)
  }

  override func delete(history: [History]) {
    let uuids = history.map { $0.id }
    viewModel.history = viewModel.history.filter { !uuids.contains($0.id) }
  }

  override func delete(reminders: [Reminder]) {
    let uuids = reminders.map { $0.id }
    viewModel.reminders = viewModel.reminders.filter { !uuids.contains($0.id) }
  }

  override func delete(medications: [Medication]) {
    let uuids = medications.map { $0.id }

    // Delete reminders associated with medications first since the data model is in
    // an invalid state if we delete the medications first.
    let reminders = viewModel.reminders.filter({ uuids.contains($0.medicationID) })
    delete(reminders: reminders)

    viewModel.medications = viewModel.medications.filter { !uuids.contains($0.id) }
  }
}

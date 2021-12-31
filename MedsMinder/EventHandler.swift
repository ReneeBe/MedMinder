//
//  EventHandler.swift
//  MedsMinder
//
//  Created by Renee Berger on 12/30/21.
//

import Foundation

@MainActor class EventHandler: ObservableObject {
  var model: Model

  init(model: Model) {
    self.model = model
  }

  func createMedication(medication: Medication) {
    self.model.add(medication: medication)
  }

  func replaceReminders(medication: Medication, reminders: [Reminder]) {
    let currentReminders = self.model.viewModel.reminders(for: medication)
    let remindersToDelete = currentReminders.filter({ !reminders.contains($0) })
    self.model.delete(reminders: remindersToDelete)

    // Only add reminders that don't exist already
    for reminder in reminders.filter({ !currentReminders.contains($0) }) {
      self.model.add(reminder: reminder)
    }
  }

  func medicationRowButtonPressed(medication: Medication, reminder: Reminder?) {
    if reminder == nil {
      let history = History(date: Date(), dosage: 1.0, medicationID: medication.id)
      self.model.add(history: history)
    } else {
      self.markReminderComplete(reminder: reminder!)
    }
  }

  func markReminderComplete(reminder: Reminder) {
    let history = History(
      date: Date(), dosage: 1.0, medicationID: reminder.medicationID, reminderID: reminder.id)
    self.model.add(history: history)
  }

  func reminderRowButtonPressed(
    reminder: Reminder, medication: Medication, rowViewState: RowViewState
  ) {
    if rowViewState == .completed {
      // TODO: Reduce duplication here since this is also in the remindersView
      let todaysHistory = self.model.viewModel.history.filter({
        Calendar.current.isDateInToday($0.date)
          && reminder.id == $0.reminderID
      })

      if todaysHistory.count > 0 {
        self.model.delete(history: todaysHistory)
      }
    } else {
      markReminderComplete(reminder: reminder)
    }
  }

  func deleteMedications(medications: [Medication]) {
    self.model.delete(medications: medications)
  }

  func deleteHistory(history: [History]) {
    self.model.delete(history: history)
  }

  func deleteReminders(reminders: [Reminder]) {
    self.model.delete(reminders: reminders)
  }
}

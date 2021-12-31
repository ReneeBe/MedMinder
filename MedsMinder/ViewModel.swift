//
//  ViewModel.swift
//  MedsMinder
//
//  Created by Renee Berger on 10/5/21.
//

import CloudKit
import Combine
import Foundation
import SwiftUI
import UIKit

// ViewModel struct that is super dumb -> pass that in as a dependency in most places
struct ViewModel: Hashable, Equatable {
  var medications: [Medication] = []
  var reminders: [Reminder] = []
  var history: [History] = []

  // TODO: We need to build a validator at some point

  init(medications: [Medication] = [], reminders: [Reminder] = [], history: [History] = []) {
    self.medications = medications.sorted()
    self.reminders = reminders.sorted()
    self.history = history.sorted()
  }

  // for previews
  static var data: ViewModel {
    return ViewModel(medications: Medication.data, reminders: Reminder.data, history: History.data)
  }

  // MARK: Non-mutating convenience methods

  func medication(for reminder: Reminder) -> Medication? {
    if let medication = medications.first(where: { $0.id == reminder.medicationID }) {
      return medication
    }
    return nil
  }

  func hasReminderBeenFullfilled(reminder: Reminder) -> Bool {
    let todaysHistory = history.filter({
      Calendar.current.isDateInToday($0.date)
        && reminder.id == $0.reminderID
    })

    return todaysHistory.count > 0
  }

  func todaysHistoryCountFor(medication: Medication) -> Int {
    let todaysHistory = history.filter({
      Calendar.current.isDateInToday($0.date)
        && medication.id == $0.medicationID
    })

    return todaysHistory.count
  }

  func intakeTimes(for medication: Medication) -> [Date] {
    var intakeTimes: [Date] = []
    let reminders = reminders.filter { $0.medicationID == medication.id }
    for reminder in reminders {
      intakeTimes.append(reminder.intakeTime)
    }
    return intakeTimes
  }

  func reminders(for medication: Medication) -> [Reminder] {
    let reminders = reminders.filter { $0.medicationID == medication.id }.sorted { a, b in
      if a.intakeTime.normalize() == b.intakeTime.normalize() {
        return a.id.uuidString < b.id.uuidString
      }
      return a.intakeTime.normalize() < b.intakeTime.normalize()
    }
    return reminders
  }

  var scheduledMedications: [Medication] {
    return medications.sorted { a, b in
      a.name < b.name
    }.reduce(
      [],
      { partialResult, medication in
        if reminders.contains(where: { $0.medicationID == medication.id }) {
          return partialResult + [medication]
        }

        return partialResult
      })
  }

  var onDemandMedications: [Medication] {
    return medications.sorted { a, b in
      a.name < b.name
    }.reduce(
      [],
      { partialResult, medication in
        if !reminders.contains(where: { $0.medicationID == medication.id }) {
          return partialResult + [medication]
        }

        return partialResult
      })
  }
}

//
//  CloudKitConstants.swift
//  MedsMinder
//
//  Created by Renee Berger on 12/30/21.
//

import Foundation

// A protocol used by the
protocol CloudKitKey: RawRepresentable {}

// Enums to use for iCloud keys, see https://medium.com/@guilhermerambo/synchronizing-data-with-cloudkit-94c6246a3fda
enum ReminderKey: String, CloudKitKey {
  case intakeTime
  case intakeAmount
  case delay
  case allowSnooze
  case notes
  case medReference
}

enum MedicationKey: String, CaseIterable, CloudKitKey {
  case name
  case details
  case format
  case color
  case shape
  case engraving
  case dosage
  case scheduled
  case reminderRef
  case reminders
  case history
}

enum HistoryKey: String, CloudKitKey {
  case date
  case dosage
  case medReference
  case reminder
}

enum RecordType: String {
  case medication = "Med"
  case history = "History"
  case reminder = "Reminder"
}

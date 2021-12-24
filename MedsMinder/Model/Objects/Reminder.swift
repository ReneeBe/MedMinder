//
//  Reminder.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/20/21.
//

import Foundation
import SwiftUI

struct Reminder: Identifiable, Codable, Hashable, Comparable {
  let id: UUID
  var medicationID: UUID
  var intakeTime: Date
  var intakeAmount: Double
  var delay: Int
  var allowSnooze: Bool
  var notes: String

  init(
    id: UUID = UUID(), medicationID: UUID, intakeTime: Date,
    intakeAmount: Double,
    delay: Int, allowSnooze: Bool, notes: String
  ) {
    self.id = id
    self.medicationID = medicationID
    self.intakeTime = intakeTime
    self.intakeAmount = intakeAmount
    self.delay = delay
    self.allowSnooze = allowSnooze
    self.notes = notes
  }

  // Do our best to have a stable (the same every time) sort here so that calling
  // .sorted does something reasonable.
  static func < (lhs: Reminder, rhs: Reminder) -> Bool {
    if lhs.intakeTime.normalize() == rhs.intakeTime.normalize() {
      if lhs.medicationID == rhs.medicationID {
        return lhs.id.uuidString < rhs.id.uuidString
      }
      return lhs.medicationID.uuidString < rhs.medicationID.uuidString
    }
    return lhs.intakeTime.normalize() < rhs.intakeTime.normalize()
  }
}

// MARK: Preview Data

extension Reminder {
  static func minutesFromNow(minutes: Int) -> Date {
    Calendar.current.date(byAdding: .minute, value: minutes, to: Date())!
  }

  static var data: [Reminder] =
    [
      Reminder(
        medicationID: Medication.data[0].id, intakeTime: minutesFromNow(minutes: 10),
        intakeAmount: 1.0, delay: 100, allowSnooze: false, notes: ""),
      Reminder(
        medicationID: Medication.data[1].id, intakeTime: minutesFromNow(minutes: 20),
        intakeAmount: 0.5, delay: 100, allowSnooze: false, notes: ""),
      Reminder(
        medicationID: Medication.data[2].id, intakeTime: minutesFromNow(minutes: -30),
        intakeAmount: 1.0, delay: 100, allowSnooze: false, notes: ""),
      Reminder(
        medicationID: Medication.data[2].id, intakeTime: minutesFromNow(minutes: -49),
        intakeAmount: 1.0, delay: 100, allowSnooze: false, notes: ""),
      Reminder(
        medicationID: Medication.data[2].id, intakeTime: minutesFromNow(minutes: 2),
        intakeAmount: 1.0, delay: 100, allowSnooze: false, notes: ""),
      Reminder(
        medicationID: Medication.data[2].id, intakeTime: minutesFromNow(minutes: -1),
        intakeAmount: 1.0, delay: 100, allowSnooze: false, notes: ""),
      Reminder(
        medicationID: Medication.data[3].id, intakeTime: minutesFromNow(minutes: -2),
        intakeAmount: 0.5, delay: 100, allowSnooze: false, notes: ""),
    ]

}

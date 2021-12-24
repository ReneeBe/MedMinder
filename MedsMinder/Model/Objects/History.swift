//
//  History.swift
//  MedsMinder
//
//  Created by Renee Berger on 10/4/21.
//

import Foundation

struct History: Identifiable, Codable, Hashable, Comparable {
  let id: UUID
  let date: Date
  var dosage: Double
  var medicationID: UUID
  var reminderID: UUID?

  init(
    id: UUID = UUID(), date: Date = Date(), dosage: Double, medicationID: UUID,
    reminderID: UUID? = nil
  ) {
    self.id = id
    self.date = date
    self.dosage = dosage
    self.medicationID = medicationID
    self.reminderID = reminderID
  }

  // Provide a stable sort here so that we now sorting the array will yield the same
  // order every time.
  static func < (lhs: History, rhs: History) -> Bool {
    if lhs.date == rhs.date {
      return lhs.id.uuidString < rhs.id.uuidString
    }
    return lhs.date < rhs.date
  }
}

// MARK: Preview Data

extension History {
  static func minutesFromNow(minutes: Int) -> Date {
    Calendar.current.date(byAdding: .minute, value: minutes, to: Date())!
  }

  static var data: [History] {
    [
      History(
        date: minutesFromNow(minutes: -1), dosage: 1.0, medicationID: Medication.data[2].id,
        reminderID: Reminder.data[3].id),
      History(
        date: minutesFromNow(minutes: -1), dosage: 1.0, medicationID: Medication.data[3].id,
        reminderID: Reminder.data[6].id),
    ]
  }
}

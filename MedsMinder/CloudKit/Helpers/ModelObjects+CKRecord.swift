//
//  ModelObjects+CKRecord.swift
//  MedsMinder
//
//  Created by Renee Berger on 12/30/21.
//

import CloudKit
import Foundation
import SwiftUI

// This file collects extensions to the model classes that assist in converting from/to CKRecord
// objects.

extension Medication {
  init(record: CKRecord, id: UUID) {
    self = Medication(
      id: id,
      name: record[.name] as! String,
      details: record[.details] as! String,
      format: Medication.Format(rawValue: record[.format] as! String) ?? .capsule,
      color: record[.color] != nil
        ? ColorUtils.MakeColors(colors: record[.color] as! [String]) : [Color.red],
      shape: record[.shape] as! [String],
      engraving: record[.engraving] as! String,
      dosage: record[MedicationKey.dosage] as! Double,
      history: record[.history] == nil ? [] : (record[.history] as! [History])
    )
  }

  func cloudKitRecord(zoneID: CKRecordZone.ID) -> CKRecord {
    let medication = CKRecord(
      recordType: RecordType.medication.rawValue, recordID: CKRecord.ID(zoneID: zoneID))
    medication[.name] = name
    medication[.details] = details
    medication[.format] = format.rawValue
    medication[.color] = [
      ColorUtils.StringFromColor(color: color[0]!),
      ColorUtils.StringFromColor(color: color[1] ?? color[0]!),
    ]
    medication[.shape] = shape
    medication[.engraving] = engraving
    medication[MedicationKey.dosage] = dosage
    medication[.history] = history
    return medication
  }
}

extension Reminder {
  init(record: CKRecord, id: UUID, medicationID: UUID) {
    self = Reminder(
      id: id,
      medicationID: medicationID,
      intakeTime: record[.intakeTime] as! Date,
      intakeAmount: record[.intakeAmount] as! Double,
      delay: record[.delay] as! Int,
      allowSnooze: (record[.allowSnooze] as! Int) != 0,
      notes: record[.notes] as! String? ?? ""
    )
  }

  func cloudKitRecord(medicationReference: CKRecord.Reference, zoneID: CKRecordZone.ID) -> CKRecord
  {
    let reminder = CloudKit.CKRecord(
      recordType: RecordType.reminder.rawValue, recordID: CKRecord.ID(zoneID: zoneID))
    reminder[.intakeTime] = intakeTime
    reminder[.intakeAmount] = intakeAmount
    reminder[.delay] = delay
    reminder[.allowSnooze] = allowSnooze
    reminder[.notes] = notes
    reminder[ReminderKey.medReference] = [medicationReference]
    return reminder
  }
}

extension History {
  init(record: CKRecord, id: UUID, medicationID: UUID, reminderID: UUID?) {
    self = History(
      id: id,
      date: record[HistoryKey.date] as! Date,
      dosage: record[HistoryKey.dosage] as! Double,
      medicationID: medicationID,
      reminderID: reminderID
    )
  }

  func cloudKitRecord(
    medicationReference: CKRecord.Reference, reminderReference: CKRecord.Reference?,
    zoneID: CKRecordZone.ID
  ) -> CKRecord {
    let history = CloudKit.CKRecord(
      recordType: RecordType.history.rawValue, recordID: CKRecord.ID(zoneID: zoneID))
    history[HistoryKey.medReference] = medicationReference
    history[HistoryKey.date] = date
    history[HistoryKey.dosage] = dosage
    history[HistoryKey.reminder] = reminderReference
    return history
  }
}

//
//  CKRecrod+CloudKitKey.swift
//  MedsMinder
//
//  Created by Renee Berger on 12/30/21.
//

import CloudKit
import Foundation

// Conveince methods to allow us to use our enums as iCloud keys, see https://medium.com/@guilhermerambo/synchronizing-data-with-cloudkit-94c6246a3fda

// TODO: Find a way to do this that isn't so repetitive
extension CKRecord {

  subscript(key: HistoryKey) -> Any? {
    get {
      return self[key.rawValue]
    }
    set {
      self[key.rawValue] = newValue as? CKRecordValue
    }
  }

  subscript(key: MedicationKey) -> Any? {
    get {
      return self[key.rawValue]
    }
    set {
      self[key.rawValue] = newValue as? CKRecordValue
    }
  }

  subscript(key: ReminderKey) -> Any? {
    get {
      return self[key.rawValue]
    }
    set {
      self[key.rawValue] = newValue as? CKRecordValue
    }
  }

}

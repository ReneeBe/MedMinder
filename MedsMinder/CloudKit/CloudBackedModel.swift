//
//  CloudBackedModel.swift
//  MedsMinder
//
//  Created by Renee Berger on 12/30/21.
//

import CloudKit
import Foundation
import os.log

@MainActor class CloudBackedModel: Model {
  // MARK: CloudKit Properties
  // TODO: Move this to the config file?
  private lazy var container = CKContainer(identifier: Config.containerIdentifier)
  private lazy var database = container.privateCloudDatabase
  private lazy var zoneID = CKRecordZone.ID(zoneName: "primary")

  // MARK: Data Processing ivars
  private var recordSyncer: RecordSyncer?

  // The saved processed data, this is in a "more raw" form than `viewModel` and contains the
  // mappings between UUID and CKRecord.ID.
  private var processedData: ProcessedRecordData = ProcessedRecordData()

  // MARK: Model Overrides

  override func startSync() async throws {
    do {
      initializeSyncers()
      try await recordSyncer?.syncPendingRecords()
      try await recordSyncer?.fetchChanges()
    } catch {
      ErrorReporter.reportCKError(error)
      throw error
    }
  }

  override func add(medication: Medication) {
    let record = medication.cloudKitRecord(zoneID: zoneID)
    Task {
      await recordSyncer?.add(record: record)
    }
  }

  override func add(reminder: Reminder) {
    guard let medicationID = self.processedData.uuidToRecord[reminder.medicationID] else {
      os_log("Error occured, a reminder was added for a medication that does not exist.")
      return
    }

    let record = reminder.cloudKitRecord(
      medicationReference: CKRecord.Reference(recordID: medicationID, action: .deleteSelf),
      zoneID: zoneID)
    Task {
      await recordSyncer?.add(record: record)
    }
  }

  override func add(history: History) {
    guard let medicationID = self.processedData.uuidToRecord[history.medicationID] else {
      os_log("Error occured, history was added for a medication that does not exist.")
      return
    }

    var reminderReference: CKRecord.Reference? = nil
    if let reminderUUID = history.reminderID,
      let reminderID = self.processedData.uuidToRecord[reminderUUID]
    {
      reminderReference = CKRecord.Reference(recordID: reminderID, action: .deleteSelf)
    }

    let record = history.cloudKitRecord(
      medicationReference: CKRecord.Reference(recordID: medicationID, action: .deleteSelf),
      reminderReference: reminderReference,
      zoneID: zoneID)
    Task {
      await recordSyncer?.add(record: record)
    }
  }

  override func delete(medications: [Medication]) {
    Task {
      // This is async (here and elsewhere) mostly because the recordSyncer is an Actor, the
      // record will appear to be deleted instantanesouly.
      await self.recordSyncer?.delete(objects: medications)
    }
  }

  override func delete(reminders: [Reminder]) {
    Task {
      await self.recordSyncer?.delete(objects: reminders)
    }
  }

  override func delete(history: [History]) {
    Task {
      await self.recordSyncer?.delete(objects: history)
    }
  }

  // MARK: Syncer Initializaiton

  // Initializes the syncers, one way to think about it is that it is syncer config. Another way
  // to think about it is that it provides the bridge between our model and CloudKit's model,
  // giving the syncer everything it needs to convert between record types.
  func initializeSyncers() {
    if recordSyncer == nil {
      let medicationRecordConverter: RecordConverter = { record, id, _ in
        Medication(
          record: record, id: id)
      }
      let reminderRecordConverter: RecordConverter = { record, id, recordToUUID in
        let medicationReferenceArray = record[ReminderKey.medReference]! as! NSArray
        let medicationReference = medicationReferenceArray[0] as! CKRecord.Reference
        let medicationID = medicationReference.recordID
        if let uuid = recordToUUID[medicationID] {
          return Reminder(record: record, id: id, medicationID: uuid)
        }
        return nil
      }
      let historyRecordConverter: RecordConverter = { record, id, recordToUUID in
        let medicationReference = record[HistoryKey.medReference]! as! CKRecord.Reference
        let medicationID = medicationReference.recordID
        let reminderReference = record[HistoryKey.reminder] as! CKRecord.Reference?
        var reminderUUID: UUID? = nil
        if let reminderID = reminderReference?.recordID, let uuid = recordToUUID[reminderID] {
          reminderUUID = uuid
        }
        if let medicationUUID = recordToUUID[medicationID] {
          return History(
            record: record, id: id, medicationID: medicationUUID, reminderID: reminderUUID)
        }
        return nil
      }
      let recordProcessor = RecordProcessor(
        recordConverters: [
          RecordType.medication.rawValue: medicationRecordConverter,
          RecordType.reminder.rawValue: reminderRecordConverter,
          RecordType.history.rawValue: historyRecordConverter,
        ],
        recordTypes: [
          RecordType.medication.rawValue, RecordType.reminder.rawValue, RecordType.history.rawValue,
        ],
        recordPublisher: { processed in
          self.processedData = processed
          self.updateViewModel(processedData: processed)
        })

      recordSyncer =
        RecordSyncer(
          database: database,
          recordProcessor: recordProcessor,
          zoneID: zoneID
        )
    }
  }

  // MARK: Helpers

  func updateViewModel(processedData: ProcessedRecordData) {
    Task {
      await MainActor.run {
        let reminders: [Reminder] =
          processedData.processedRecords.filter { $0 is Reminder } as! [Reminder]
        let medications: [Medication] =
          processedData.processedRecords.filter { $0 is Medication } as! [Medication]
        let history: [History] =
          processedData.processedRecords.filter { $0 is History } as! [History]

        self.viewModel = ViewModel(
          medications: medications,
          reminders: reminders,
          history: history)

        LocalNotificationManager.sharedNotificationManager.schedule(viewModel: viewModel)
      }
    }
  }
}

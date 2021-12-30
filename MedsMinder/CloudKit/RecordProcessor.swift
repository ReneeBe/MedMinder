//
//  RecordPublisher.swift
//  MedsMinder
//
//  Created by Renee Berger on 12/30/21.
//

import CloudKit
import Foundation

// Alias for a function/closure that can convert a CKRecord into an object from our datamodel.
// Ideally we would use parameterized types or protoocls here and elsewhere in the file to restrict
// the type to be one of our model classes, or at least Identifiable, however there wasn't an easy
// way to do it when I wrote this code -- partially a limitation of Swift and partially my knowledge.
// The params here are the record to convert, the ID that record should have and a mapping of all
// currently known CKRecord.ID -> UUID relationships so that CKRecord.References can be mapped to
// our internal UUIDs.
typealias RecordConverter = (CKRecord, UUID, [CKRecord.ID: UUID]) -> Any?

// The output of the RecordProcessor grouped into one object for convenience
struct ProcessedRecordData {
  var processedRecords: [Any] = []
  var recordToUUID: [CKRecord.ID: UUID] = [:]
  var uuidToRecord: [UUID: CKRecord.ID] = [:]
}

struct RecordProcessor {
  // A mapping of CloudKit record types to converter functions, used when processing records.
  var recordConverters: [String: RecordConverter]

  // Types of records that the processor supports, order is significant so that we can proceess types that depend
  // on each other.
  var recordTypes: [String]

  // This closure is called when new records have been processed, it is only called on changes (or
  // at least that's the intention, but this may not always work as intendend).
  var recordPublisher: (ProcessedRecordData) -> Void

  // The last processed version of our data.
  var processedRecordData: ProcessedRecordData = ProcessedRecordData()

  // Raw records help as a map, the map helps ensure there are no duplicates and allows us to compare
  // vs the new records passed in without having to worry about order
  var lastRawRecords: [CKRecord.ID: CKRecord] = [:]

  // This method uses the parameters to the struct to convert from CKRecord to the classes used
  // in our model.
  mutating func processRecords(currentRecords: [CKRecord.ID: CKRecord]) {
    // Early exit if the records have not changed
    if lastRawRecords == currentRecords {
      return
    }

    lastRawRecords = currentRecords
    let records = currentRecords.values
    var recordToUUID: [CKRecord.ID: UUID] = processedRecordData.recordToUUID
    var uuidToRecord: [UUID: CKRecord.ID] = processedRecordData.uuidToRecord
    var processedRecords: [Any] = []
    for recordType in recordTypes {
      guard let recordConverter = recordConverters[recordType] else {
        assertionFailure("Missing converter for record type listed as supported by the processor.")
        continue
      }
      let recordsOfType = records.filter { $0.recordType == recordType }
      for record in recordsOfType {
        recordToUUID[record.recordID] = recordToUUID[record.recordID, default: UUID()]
        let uuid = recordToUUID[record.recordID]!
        uuidToRecord[uuid] = record.recordID
        if let processedRecord = recordConverter(record, uuid, recordToUUID) {
          processedRecords.append(processedRecord)
        }
      }
    }
    processedRecordData = ProcessedRecordData(
      processedRecords: processedRecords, recordToUUID: recordToUUID, uuidToRecord: uuidToRecord)
    recordPublisher(processedRecordData)
  }
}

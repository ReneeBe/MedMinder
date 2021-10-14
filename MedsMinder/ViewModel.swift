//
//  ViewModel.swift
//  MedsMinder
//
//  Created by Renee Berger on 10/5/21.
//

import Foundation
import os.log
import CloudKit
import UIKit
import SwiftUI

class ViewModel: ObservableObject {

    // MARK: - Properties
    /// The CloudKit container to use. Update with your own container identifier.
    private let container = CKContainer(identifier: Config.containerIdentifier)

    /// This sample uses the private database, which requires a logged in iCloud account.
    private lazy var database = container.privateCloudDatabase

    /// This sample uses a singleton record ID, referred to by this property.
    /// CloudKit uses `CKRecord.ID` objects to represent record IDs.
//    private let recordName: CKRecord.ID

    /// Publish the fetched last person to our view.
    @Published var medData: [Med] = []
    var oldReminderRecord = CKRecord(recordType: "Reminder")
    var reminderRecordIDToUpdate = CKRecord.ID()
//    @Published var medData = MedData().meds

    // MARK: - Init
    init() {
        // Use a different unique record ID if testing.
//        lastPersonRecordID = CKRecord.ID(recordName: isTesting ? "lastPersonTest" : "lastPerson")
//        getLastPerson()
        getData()
//        medData.map { $0 }
//            .assign(to: &$contactNames)
    }

    // MARK: - API
    /// Saves the given name as the last person in the database.
    /// - Parameters:
    ///   - name: Name to attach to the record as the last person.
    ///   - completionHandler: An optional handler to process completion `success` or `failure`.
    
//    func saveNewRecord(med: Med, completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
//        var newMed = CKRecord(recordType: "Med")
////        for med in meds {
////            let newMed = CKRecord(recordType: "Med")
//            newMed["name"] = med.name
//            newMed["details"] = med.details
//            newMed["format"] = med.format
//    //        newMed["color"] = (UIColor(med.color!) as! __CKRecordObjCValue)
//            newMed["shape"] = med.shape
//            newMed["engraving"] = med.engraving
//            newMed["dosage"] = med.dosage
//            newMed["scheduled"] = med.scheduled == true ? 1 : 0
////        }
//        database.save(newMed, completionHandler: (CKRecord?, Error?) -> Void)
//
//    }
    
    
    func updateAndSave(meds: [Med], completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
        var newMeds = [CKRecord(recordType: "Med")]
        for med in meds {
            let newMed = CKRecord(recordType: "Med")
            newMed["name"] = med.name
            newMed["details"] = med.details
            newMed["format"] = med.format
    //        newMed["color"] = (UIColor(med.color!) as! __CKRecordObjCValue)
            newMed["shape"] = med.shape
            newMed["engraving"] = med.engraving
            newMed["dosage"] = med.dosage
            newMed["scheduled"] = med.scheduled == true ? 1 : 0
            newMeds.append(newMed)
        }
        
        let saveOperation = CKModifyRecordsOperation(recordsToSave: newMeds)
        saveOperation.savePolicy = .allKeys

        saveOperation.perRecordCompletionBlock = { record, error in
            if let error = error {
                self.reportError(error)
            }

            self.getData()
        }

        saveOperation.modifyRecordsCompletionBlock = { _, _, error in
            if let error = error {
                self.reportError(error)
                completionHandler?(.failure(error))
            } else {
                // If a completion was supplied, like during tests, call it back now.
                completionHandler?(.success(()))
            }
        }

        database.add(saveOperation)
    }
    
    
    
    func saveHistory(meds: [Med], completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
        var newMeds = [CKRecord(recordType: "Med")]
        for med in meds {
            let newMed = CKRecord(recordType: "Med")
            newMed["name"] = med.name
            newMed["details"] = med.details
            newMed["format"] = med.format
    //        newMed["color"] = (UIColor(med.color!) as! __CKRecordObjCValue)
            newMed["shape"] = med.shape
            newMed["engraving"] = med.engraving
            newMed["dosage"] = med.dosage
            newMed["scheduled"] = med.scheduled == true ? 1 : 0
            newMeds.append(newMed)
        }
        
        let saveOperation = CKModifyRecordsOperation(recordsToSave: newMeds)
        saveOperation.savePolicy = .allKeys

        saveOperation.perRecordCompletionBlock = { record, error in
            if let error = error {
                self.reportError(error)
            }

            self.getData()
        }

        saveOperation.modifyRecordsCompletionBlock = { _, _, error in
            if let error = error {
                self.reportError(error)
                completionHandler?(.failure(error))
            } else {
                // If a completion was supplied, like during tests, call it back now.
                completionHandler?(.success(()))
            }
        }

        database.add(saveOperation)
    }
    
    
    func saveRecord(meds: [Med], completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
        var newMeds = [CKRecord(recordType: "Med")]
        for med in meds {
            let newMed = CKRecord(recordType: "Med")
            newMed["name"] = med.name
            newMed["details"] = med.details
            newMed["format"] = med.format
    //        newMed["color"] = (UIColor(med.color!) as! __CKRecordObjCValue)
            newMed["shape"] = med.shape
            newMed["engraving"] = med.engraving
            newMed["dosage"] = med.dosage
            newMed["scheduled"] = med.scheduled == true ? 1 : 0
            newMeds.append(newMed)
        }
        
        let saveOperation = CKModifyRecordsOperation(recordsToSave: newMeds)
        saveOperation.savePolicy = .allKeys

        saveOperation.perRecordCompletionBlock = { record, error in
            if let error = error {
                self.reportError(error)
            }

            self.getData()
        }

        saveOperation.modifyRecordsCompletionBlock = { _, _, error in
            if let error = error {
                self.reportError(error)
                completionHandler?(.failure(error))
            } else {
                // If a completion was supplied, like during tests, call it back now.
                completionHandler?(.success(()))
            }
        }

        database.add(saveOperation)
    }

//    func updateRecords(meds: [Med], completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
////        var allMeds = []
//        for med in medData {
//            recordName = CKRecord.ID(recordName: med.recordID)
//
//
//            database.fetch(withRecordID: recordName) { (record, error) in
//                if error == nil {
//                    record?.dosage = med.dosage
//                    record?.history = med.history
//                    record?.reminders = med.reminders
//                    record?.scheduled = med.scheduled
//                    self.database.save(record!, completionHandler: { (newRecord, error) in
//                        if error == nil {
//                            print("record saved!: \(med.name)")
//                        } else {
//                            print("Record Not Saved")
//                        }
//                    })
//                } else {
//                    print("Could not fetch record")
//                }
//
//            }
//        }
//
//    }

    
    /// Deletes the last person record.
    /// - Parameter completionHandler: An optional handler to process completion `success` or `failure`.
//    func deleteLastPerson(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
//        database.delete(withRecordID: lastPersonRecordID) { recordID, error in
//            if let recordID = recordID {
//                os_log("Record with ID \(recordID.recordName) was deleted.")
//            }
//
//            if let error = error {
//                self.reportError(error)
//
//                // If a completion was supplied, pass along the error here.
//                completionHandler?(.failure(error))
//            } else {
//                // If a completion was supplied, like during tests, call it back now.
//                completionHandler?(.success(()))
//            }
//        }
//    }

    /// Fetches the last person record and updates the published `lastPerson` property in the VM.
    /// - Parameter completionHandler: An optional handler to process completion `success` or `failure`.
    func getData(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
        // Here, we will use the convenience "fetch" method on CKDatabase, instead of
        // CKFetchRecordsOperation, which is more flexible but also more complex.
//        var newMeds: [Med] = []
        var newMeds = [Med]()

        let predicate = NSPredicate(value: true)
        
        let medQuery = CKQuery(recordType: "Med", predicate: predicate)

        medQuery.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let medOperation = CKQueryOperation(query: medQuery)
        medOperation.desiredKeys = ["name", "details", "format", "color", "shape", "engraving", "dosage", "scheduled", "reminders", "history"]
        
        medOperation.recordFetchedBlock = { record in
                let med = Med(
                    name: record["name"] as! String,
                    details: record["details"] as! String,
                    format: record["format"] as! String,
                    color: record["color"] as! Color?,
                    shape: record["shape"] as! [String],
                    engraving: record["engraving"] as! String,
                    dosage: record["dosage"] as! Double,
                    scheduled: ((record["scheduled"] as! Int) != 0),
                    reminders: record["reminders"] == nil ? [] : (record["reminders"] as! [Reminder]),
                    history: record["history"] == nil ? [] : (record["history"] as! [History])
                )
                print(med)
                newMeds.append(med)
        }
        
        medOperation.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
                    print("newMeds before updating medData: \(newMeds)")
                    self.medData = newMeds
                    print("we got the data!: \(medData)")
//                    self.tableView.reloadData()
                } else {
                    print("we got an error in the completion block naynay")
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of whistles; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                    print("please try again: \(error!.localizedDescription)")
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                }
            }
        }
        database.add(medOperation)
    }

    func deleteMeds(name: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
         // In this contrived example, Contact records only store a name, so rather than requiring the
         // unique ID to delete a Contact, we'll use the first ID that matches the name to delete.
        let predicate = NSPredicate(format: "name = %@", name)
        let query = CKQuery(recordType: "Med", predicate: predicate)
        var recordID = CKRecord.ID()
        
        database.perform(query, inZoneWith: nil) { records, error in
            guard let records = records else { return }
            recordID = records[0].recordID
        }
        
         let deleteOperation = CKModifyRecordsOperation(recordIDsToDelete: [recordID])

         deleteOperation.modifyRecordsCompletionBlock = { _, _, error in
             if let error = error {
                 completionHandler(.failure(error))
                 debugPrint("Error deleting contact: \(error)")
             } else {
                 DispatchQueue.main.async {
                    let index = self.medData.firstIndex(where: { $0.name == name })
                    self.medData.remove(at: index!)
                    print("here are the meds after the supposed deletion: \(self.medData)")
                     completionHandler(.success(()))
                 }
             }
         }
         database.add(deleteOperation)
     }

    
    
    // MARK: - Helpers
    
    
    
/// Fetches the last reminder record
/// - Parameter completionHandler: An optional handler to process completion `success` or `failure`.
    func getLastReminderOrCallCreateReminder(med: Med, reminder: Reminder, name: String, completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
//        var predicate: NSPredicate = nil
        let predicate = NSPredicate(format: "medName =%@", name)
        
        let reminderQuery = CKQuery(recordType: "Reminder", predicate: predicate)
        var recordID = CKRecord.ID()
        
        let reminderOperation = CKQueryOperation(query: reminderQuery)
        
        database.perform(reminderQuery, inZoneWith: nil) { records, error in
            guard let records = records else { return }
            recordID = records[0].recordID
        }
        
        
//        reminderOperation.desiredKeys = ["medName", "intakeType", "intakeTimes", "intakeAmount", "delay", "allowSnooze", "notes"]
        
        // Here, we will use the convenience "fetch" method on CKDatabase, instead of
        // CKFetchRecordsOperation, which is more flexible but also more complex.
        database.fetch(withRecordID: recordID) { record, error in
            if let record = record {
                os_log("Record with ID \(record.recordID.recordName) was fetched.")
                if (record["medName"] as? String) != nil {
                    DispatchQueue.main.async {
                        self.oldReminderRecord = record
                        self.reminderRecordIDToUpdate = recordID
//                        return {record, recordID}
                    }
                }
            }
            if record == nil {
                self.createReminderRecord(med: med, reminder: reminder)
            }

            if let error = error {
                self.reportError(error)

                // If a completion was supplied, pass along the error here.
                completionHandler?(.failure(error))
            } else {
                // If a completion was supplied, like during tests, call it back now.
                completionHandler?(.success(()))
            }
        }
    }
    
    private func createReminderRecord(med: Med, reminder: Reminder) {
        var medRecord = CKRecord(recordType: "Med")
        
        let predicate = NSPredicate(format: "name =%@", med.name)
        
        let medQuery = CKQuery(recordType: "Med", predicate: predicate)
        var medRecordID = CKRecord.ID()
        
        
        database.perform(medQuery, inZoneWith: nil) { records, error in
            guard let records = records else { return }
            medRecord = records[0]
            medRecordID = records[0].recordID
        }
//        var recordID = CKRecord.ID(rec)
        let newReminder = CKRecord(recordType: "Reminder")
        newReminder["medName"] = reminder.medName
        newReminder["intakeType"] = reminder.intakeType
        newReminder["intakeTimes"] = reminder.intakeTimes
        newReminder["intakeAmount"] = reminder.intakeAmount
        newReminder["delay"] = reminder.delay
        newReminder["allowSnooze"] = reminder.allowSnooze
        newReminder["notes"] = reminder.notes
        
                
//        let reference = CKRecord.Reference(recordID: medRecordID, action: .deleteSelf)
        
//        medRecord["reminders"] = [newReminder] as [CKRecord.Reference]
        

//        return newReminder
        
        let saveReminderOperation = CKModifyRecordsOperation(recordsToSave: [newReminder])
        saveReminderOperation.savePolicy = .allKeys

        saveReminderOperation.perRecordCompletionBlock = { record, error in
            if let error = error {
                self.reportError(error)
            }

            self.getData()
        }

        saveReminderOperation.modifyRecordsCompletionBlock = { _, _, error in
            if let error = error {
                self.reportError(error)
//                completionHandler?(.failure(error))
            } else {
                // If a completion was supplied, like during tests, call it back now.
//                completionHandler?(.success(()))
            }
        }

        database.add(saveReminderOperation)
    }
    
    private func reportError(_ error: Error) {
        guard let ckerror = error as? CKError else {
            os_log("Not a CKError: \(error.localizedDescription)")
            return
        }

        switch ckerror.code {
        case .partialFailure:
            // Iterate through error(s) in partial failure and report each one.
            let dict = ckerror.userInfo[CKPartialErrorsByItemIDKey] as? [NSObject: CKError]
            if let errorDictionary = dict {
                for (_, error) in errorDictionary {
                    reportError(error)
                }
            }

        // This switch could explicitly handle as many specific errors as needed, for example:
        case .unknownItem:
            os_log("CKError: Record not found.")

        case .notAuthenticated:
            os_log("CKError: An iCloud account must be signed in on device or Simulator to write to a PrivateDB.")

        case .permissionFailure:
            os_log("CKError: An iCloud account permission failure occured.")

        case .networkUnavailable:
            os_log("CKError: The network is unavailable.")

        default:
            os_log("CKError: \(error.localizedDescription)")
        }
    }
    
    
    enum PrivateSyncError: Error {
        case medNotFound
    }

}

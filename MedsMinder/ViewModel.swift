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
    @Published var reminderData: [Reminder] = []
    
    var oldReminderRecord = CKRecord(recordType: "Reminder")
    var reminderRecordIDToUpdate = CKRecord.ID()
//    @Published var medData = MedData().meds
//    let queue = OperationQueue().addOperation(getReminderData(self: self)).addOperation(getData(self.self))
    

    // MARK: - Init
    init() {
        // Use a different unique record ID if testing.
//        lastPersonRecordID = CKRecord.ID(recordName: isTesting ? "lastPersonTest" : "lastPerson")
//        getLastPerson()
//        do {
//            medData = try await getMedData()
//////            try await getReminderData()
//        } catch {
//            print("error at init: /(error)")
////            throw error
//        }
        getMedData()
        getReminderData()
//        medData.map { $0 }
//            .assign(to: &$contactNames)
    }

    // MARK: - API
    func getMedData(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
        var newMeds = [Med]()
        let predicate = NSPredicate(value: true)
        let medQuery = CKQuery(recordType: "Med", predicate: predicate)
        medQuery.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let medOperation = CKQueryOperation(query: medQuery)
        medOperation.desiredKeys = ["name", "details", "format", "color", "shape", "engraving", "dosage", "scheduled", "reminders", "reminderRef", "history"]

        medOperation.recordMatchedBlock = { recordID, result in
                // now, unwrap result, was there an error?
            switch result {
                case .success(let record):
                    let med = Med(
                        name: record["name"] as! String,
                        details: record["details"] as! String,
                        format: record["format"] as! String,
                        color: record["color"] as! Color?,
                        shape: record["shape"] as! [String],
                        engraving: record["engraving"] as! String,
                        dosage: record["dosage"] as! Double,
                        scheduled: ((record["scheduled"] as! Int) != 0),
//                        reminders: ((record["reminderRef"].count) as! Int),
                        history: record["history"] == nil ? [] : (record["history"] as! [History])
                    )
//                    print(med)
                    newMeds.append(med)
            case .failure(let error):
                print("error in fetching med record: \(error)")
            }
        }

        medOperation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                        self.medData = newMeds
//                        print("we got the data for meds!: \(self.medData)")
                case .failure(let error):
                    print("we got an error in the completion block med operation")
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of medications; please try again: \(error.localizedDescription)", preferredStyle: .alert)
                    print("please try again: \(error.localizedDescription)")
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                }
            }
        }
        database.add(medOperation)
    }
    
    
    func getReminderData(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
        var newReminders = [Reminder]()
        let reminderPredicate = NSPredicate(value: true)
        let reminderQuery = CKQuery(recordType: "Reminder", predicate: reminderPredicate)
        reminderQuery.sortDescriptors = [NSSortDescriptor(key: "intakeTime", ascending: true)]

        let reminderOperation = CKQueryOperation(query: reminderQuery)
        
        reminderOperation.recordMatchedBlock = { recordID, result in
            switch result {
                case .success(let record):
                    let reminder = Reminder(
                        medName: record["medName"] as! String,
                        intakeType: record["intakeType"] as! String,
                        intakeTime: record["intakeTime"] as! Date,
                        intakeAmount: record["intakeAmount"] as! Double,
                        delay: record["delay"] as! Int,
                        allowSnooze: (record["allowSnooze"] as! Int) != 0,
                        notes: record["notes"] as! String? ?? ""
                    )
//                    print(reminder)
                    newReminders.append(reminder)
                case .failure(let error):
                    print("error in fetching reminder record: \(error)")
            }
        }
            
        reminderOperation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.reminderData = newReminders
//                    print("we got the data for reminders: \(self.reminderData)")
                case .failure(let error):
                    print("we got an error in the completion block reminder operation")
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of reminders; please try again: \(error.localizedDescription)", preferredStyle: .alert)
                    print("please try again: \(error.localizedDescription)")
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                }
            }
        }
        
        database.add(reminderOperation)
    }
    
    /// Saves the given name as the last person in the database.
    /// - Parameters:
    ///   - name: Name to attach to the record as the last person.
    ///   - completionHandler: An optional handler to process completion `success` or `failure`.
    
//    func saveNewRecord(med: Med, completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
//        var newMed: CKRecord
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
        var newMeds: [CKRecord] = []
        for med in meds {
//            let predicate = NSPredicate(format: "name = %@", med.name)
//            let query = CKQuery(recordType: "Med", predicate: predicate)
//            var recordID = CKRecord.ID()
            
            
            
//            database.fetch(query) { records, error in
//                guard records != nil else { return }
//                recordID = records[0].recordID
                
                let newMed = CKRecord(recordType: "Med")
                newMed["name"] = med.name
                newMed["details"] = med.details
                newMed["format"] = med.format
        //        newMed["color"] = (UIColor(med.color!) as! __CKRecordObjCValue)
                newMed["shape"] = med.shape
                newMed["engraving"] = med.engraving
                newMed["dosage"] = med.dosage
                newMed["scheduled"] = med.scheduled == true ? 1 : 0
//                newMed["reminders"] = med.reminders
                newMeds.append(newMed)
        
                let saveOperation = CKModifyRecordsOperation(recordsToSave: newMeds)
                saveOperation.savePolicy = .changedKeys

                saveOperation.perRecordSaveBlock = { recordID, result in
                    switch result {
                        case .success(_):
                            print("saving new record!")
                        case .failure(let error):
                            print("error in perRecordSaveBlock in updateAndSaveRecord: \(error)")
                            self.reportError(error)
                    }
                }

                saveOperation.modifyRecordsResultBlock = { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            print("saved the new record!")
                            completionHandler?(.success(()))
                        case .failure(let error):
                            print("error in modifyRecordsResultBlock in saveRecord: \(error)")
                            self.reportError(error)
                            completionHandler?(.failure(error))
                        }
                    }
                }
                getMedData()
                database.add(saveOperation)
//            }
        }
            
            
            
            

    }
    
    func saveRecord(meds: [Med], completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
        var newMeds: [CKRecord] = []
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

        saveOperation.perRecordSaveBlock = { recordID, result in
            switch result {
                case .success(_):
                    print("saving new record!")
                case .failure(let error):
                    print("error in perRecordSaveBlock in saveRecord: \(error)")
                    self.reportError(error)
            }
            self.getMedData()
        }

        saveOperation.modifyRecordsResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(_):
                        print("success in save record!")
    //                    self.medData.append()
                    case .failure(let error):
                        self.reportError(error)
                        completionHandler?(.failure(error))
                }
            }
        }

        database.add(saveOperation)
    }
    
        
    func findMedForRecID(med: Med, reminders: [Reminder]?, process: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let predicate = NSPredicate(format: "name = %@", med.name)
        let findQuery = CKQuery(recordType: "Med", predicate: predicate)
        let findOperation = CKQueryOperation(query: findQuery)
        var recID = CKRecord.ID()
        
        findOperation.recordMatchedBlock = { recordID, result in
            switch result {
                case .success(_):
                    recID = recordID
                case .failure(let error):
                    print("error in fetching Med recordID to delete: \(error)")
            }
        }
        
        findOperation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(_):
                        print("we found it!")
                        if process == "delete" {
                            self.deleteMeds(recID: recID) { _ in }
                        } else if process == "update reminders" {
//                            self.findReminderForRecID(
                            self.findAllRemindersForMed(med: med, medRecID: recID, reminders: reminders ?? [], process: "update reminders") { _ in}
                        }
                    case .failure(let error):
                        print("we got an error in the result block to find the recordID of the med to delete: \(error)")
                }
            }
        }
        database.add(findOperation)
//        return recID
    }
    
    func findReminderForRecID(reminder: Reminder, process: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        
//        let predicate = NSPredicate(format: "medName == %@ && intakeTime == %@", reminder.medName, reminder.intakeTime)
        let predicate = NSCompoundPredicate(
            type: .and,
            subpredicates: [
                NSPredicate(format: "medName = %@", reminder.medName),
                NSPredicate(format: "intakeTime = %@", reminder.intakeTime as CVarArg)
            ]
        )
        
        let findQuery = CKQuery(recordType: "Reminder", predicate: predicate)
        let findOperation = CKQueryOperation(query: findQuery)
        var recID = CKRecord.ID()
        
        findOperation.recordMatchedBlock = { recordID, result in
            switch result {
                case .success(_):
                    recID = recordID
                case .failure(let error):
                    print("error in fetching Med recordID to delete: \(error)")
            }
        }
        
        findOperation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(_):
                        print("we found it!")
                        if process == "delete" {
                            self.deleteMeds(recID: recID) { _ in }
                        }
                        
                    case .failure(let error):
                        print("we got an error in the result block to find the recordID of the med to delete: \(error)")
                }
            }
        }
        database.add(findOperation)
//        return recID
    }
    
    
    func deleteMeds(recID: CKRecord.ID, completionHandler: @escaping (Result<Void, Error>) -> Void) {
//    func deleteMeds(med: Med, completionHandler: @escaping (Result<Void, Error>) -> Void) {
//        var recID = CKRecord.ID()
//        let recID = findMedToDelete(med: med) { _ in }


        let deleteMedRecordOperation = CKModifyRecordsOperation(recordIDsToDelete: [recID])
        deleteMedRecordOperation.perRecordDeleteBlock = {recordID, result in
            switch result {
                case.success(_):
                    print("we're deleting the med record!")
                case .failure(let error):
                    print("error in deleting med record: \(error)")
            }
        }
        
        deleteMedRecordOperation.modifyRecordsResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(_):
                        print("success in delete record!")
                        self.getMedData()
                        self.getReminderData()
                case .failure(let error):
                    self.reportError(error)
                    print("we hit an error in the modify records result block of deleteMeds: \(error)")
                    completionHandler(.failure(error))
                }
            }
        }
        database.add(deleteMedRecordOperation)
     }

    
    
    // MARK: - Helpers
    
    
    
/// Fetches the last reminder record
/// - Parameter completionHandler: An optional handler to process completion `success` or `failure`.
    func getLastReminderOrCallCreateReminder(med: Med, reminders: [Reminder], name: String, completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
//        var predicate: NSPredicate = nil
//        let predicate = NSPredicate(format: "medName =%@", name)
        let recordID = CKRecord.ID()
        
//        let reminderQuery = CKQuery(recordType: "Reminder", predicate: predicate)
//        var recordID = CKRecord.ID()
        
//        let reminderOperation = CKQueryOperation(query: reminderQuery)
        
//        database.perform(reminderQuery, inZoneWith: nil) { records, error in
//            guard let records = records else { return }
//            //                self.createReminderRecord(med: med, reminder: reminder)
//
//            recordID = records[0].recordID
//
////            if records[0] != nil {
////            }
//        }

        
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
                print("renee you gotta g back to the next line because apparently this function is being used")
//                self.createReminderRecord(med: med, reminders: reminders)
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
    
    
    func findAllRemindersForMed(med: Med, medRecID: CKRecord.ID, reminders: [Reminder], process: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let predicate = NSPredicate(format: "medName = %@", med.name)
        let findQuery = CKQuery(recordType: "Reminder", predicate: predicate)
        let findOperation = CKQueryOperation(query: findQuery)
        var reminderRecIDs: [CKRecord.ID] = []
        
        findOperation.recordMatchedBlock = { recordID, result in
            switch result {
                case .success(_):
                    reminderRecIDs.append(recordID)
                case .failure(let error):
                    print("error in fetching all reminders to delete them: \(error)")
            }
        }
        
        findOperation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(_):
                    self.createReminderRecord(med: med, medRecID: medRecID, reminders: reminders, reminderRecIDs: reminderRecIDs) {_ in}
                    case .failure(let error):
                        print("we got an error in the result block of findAllRemindersForMed to find the recordID of all the meds we need to delete: \(error)")
                }
            }
        }
        database.add(findOperation)
    }
    
    func createReminderRecord(med: Med, medRecID: CKRecord.ID, reminders: [Reminder], reminderRecIDs: [CKRecord.ID], completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let referenceToMedRecord = CKRecord.Reference(recordID: medRecID, action: .deleteSelf)
        var newReminders: [CKRecord] = []
        var newReferencesToReminders: [CKRecord.Reference] = []
        
        
        for reminder in reminders {
    //        var recordID = CKRecord.ID(rec)
            let newReminder = CKRecord(recordType: "Reminder")
            newReminder["medName"] = reminder.medName
            newReminder["intakeType"] = reminder.intakeType
            newReminder["intakeTime"] = reminder.intakeTime
            newReminder["intakeAmount"] = reminder.intakeAmount
            newReminder["delay"] = reminder.delay
            newReminder["allowSnooze"] = reminder.allowSnooze
            newReminder["notes"] = reminder.notes
            newReminder["medReference"] = [referenceToMedRecord]
//            newReminder.setParent(medRecord)
            newReminders.append(newReminder)
            let referenceToReminder = CKRecord.Reference(recordID: newReminder.recordID, action: .none)
            newReferencesToReminders.append(referenceToReminder)
        }
        
        let medRecord = CKRecord(recordType: "Med", recordID: medRecID)
        
        medRecord["name"] = med.name
        medRecord["details"] = "We've changed this one a second time and here's the proof"
        medRecord["format"] = med.format
//        medRecord["color"] = (UIColor(med.color!) as! __CKRecordObjCValue)
        medRecord["shape"] = med.shape
        medRecord["engraving"] = med.engraving
        medRecord["dosage"] = med.dosage
        medRecord["scheduled"] = med.scheduled == true ? 1 : 0
//            medRecord["reminders"] = med.reminders as __CKRecordObjCValue
//            newMeds.append(newMed)
        medRecord["reminderRef"] = newReferencesToReminders
        print("here is medRecord: \(medRecord)")
        newReminders.append(medRecord)
        
        
        
        let updateAndSaveRemindersOperation = CKModifyRecordsOperation(recordsToSave: newReminders, recordIDsToDelete: reminderRecIDs)
        updateAndSaveRemindersOperation.savePolicy = .allKeys
        
        updateAndSaveRemindersOperation.modifyRecordsResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(_):
                        print("success in updating reminders records!")
//                        self.getMedData()
//                        self.getReminderData()
//                        print("medData: \(self.medData), reminderData: \(self.reminderData)")

                    case .failure(let error):
                        self.reportError(error)
                        print("we hit an error in the modify records result block of createReminderRecord: \(error)")
//                        completionHandler(.failure(error))
                    
                }
                    
            }

        }
        self.database.add(updateAndSaveRemindersOperation)

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

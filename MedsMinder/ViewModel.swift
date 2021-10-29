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
        getAllData()
//        getReminderData()
//        getData()
//        getReminderData()
//        medData.map { $0 }
//            .assign(to: &$contactNames)
    }

    // MARK: - API
    func getReminderData(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
        var newReminders = [Reminder]()
        let reminderPredicate = NSPredicate(value: true)
        let reminderQuery = CKQuery(recordType: "Reminder", predicate: reminderPredicate)
        reminderQuery.sortDescriptors = [NSSortDescriptor(key: "intakeTime", ascending: true)]

        let reminderOperation = CKQueryOperation(query: reminderQuery)
        
        reminderOperation.recordFetchedBlock = { remRec in
            guard remRec != nil else { return }

//                guard let remRec = remRec else { return }
//                for rec in remRec {
                let reminder = Reminder(
                    medName: remRec["medName"] as! String,
                    intakeType: remRec["intakeType"] as! String,
                    intakeTime: remRec["intakeTime"] as! Date,
                    intakeAmount: remRec["intakeAmount"] as! Double,
                    delay: remRec["delay"] as! Int,
                    allowSnooze: (remRec["allowSnooze"] as! Int) != 0,
                    notes: remRec["notes"] as! String? ?? ""
                )
                print(reminder)
                print("we got reminder \(reminder)")
//                medRecordReminders.append(reminder)
                newReminders.append(reminder)
            }
//            print("medRecordReminders incoming:")
//            print(medRecordReminders)
            print("newReminders incoming")
            print(newReminders)
            
//            }
        
        reminderOperation.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
//                        print("newMeds before updating medData: \(newMeds)")
//                        self.medData = newMeds
//                    print("here are all the medRecordReminders we collected this time: \(medRecordReminders)")
                    self.reminderData = newReminders
//                        print("we got the data!: \(medData)")
                    print("we got the data for reminders: \(reminderData)")
//                    self.tableView.reloadData()
                } else {
                    print("we got an error in the completion block")
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of medications; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                    print("please try again: \(error!.localizedDescription)")
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                }
            }
            
        }
    }
    
    
    
    func getAllData(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
        var newMeds = [Med]()
        var newReminders = [Reminder]()
//        var newHistory = [History]()
        
        let predicate = NSPredicate(value: true)
        
        let medQuery = CKQuery(recordType: "Med", predicate: predicate)

        medQuery.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let medOperation = CKQueryOperation(query: medQuery)
        medOperation.desiredKeys = ["name", "details", "format", "color", "shape", "engraving", "dosage", "scheduled", "reminders", "reminderRef", "history"]
//        let reminderOperation = CKQueryOperation(query: reminderQuery)
        
        medOperation.recordFetchedBlock = { record in
//            let reminderRef = record["reminderRef"]
            let currentMedRecordID = record.recordID
            var medRecordReminders: [Reminder] = []
            
            let reminderPredicate = NSPredicate(format: "medReference CONTAINS %@", currentMedRecordID)
            let reminderQuery = CKQuery(recordType: "Reminder", predicate: reminderPredicate)
            reminderQuery.sortDescriptors = [NSSortDescriptor(key: "intakeTime", ascending: true)]

            let reminderOperation = CKQueryOperation(query: reminderQuery)

            reminderOperation.recordFetchedBlock = { remRec in
//                if remRec
                guard remRec != nil else { return }
//                guard let remRec = remRec else { return }
//                for rec in remRec {
                    let reminder = Reminder(
                        medName: remRec["medName"] as! String,
                        intakeType: remRec["intakeType"] as! String,
                        intakeTime: remRec["intakeTime"] as! Date,
                        intakeAmount: remRec["intakeAmount"] as! Double,
                        delay: remRec["delay"] as! Int,
                        allowSnooze: (remRec["allowSnooze"] as! Int) != 0,
                        notes: remRec["notes"] as! String? ?? ""
                    )
                    print(reminder)
                    print("we got reminder \(reminder)")
                    medRecordReminders.append(reminder)
                    newReminders.append(reminder)
                }
                print("medRecordReminders incoming:")
                print(medRecordReminders)
                print("newReminders incoming")
                print(newReminders)

//            }

            reminderOperation.queryCompletionBlock = { [unowned self] (cursor, error) in
                DispatchQueue.main.async {
                    if error == nil {
//                        print("newMeds before updating medData: \(newMeds)")
//                        self.medData = newMeds
                        print("here are all the medRecordReminders we collected this time: \(medRecordReminders)")
                        self.reminderData = newReminders
//                        print("we got the data!: \(medData)")
                        print("we got the data for reminders: \(reminderData)")
    //                    self.tableView.reloadData()
                    } else {
                        print("we got an error in the completion block")
                        let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of medications; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                        print("please try again: \(error!.localizedDescription)")
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                    }
                }

            }
            
            self.database.add(reminderOperation)

            
//            if let reminds = reminderRef {
//                for ref in reminds {
//                    let refRecordID = ref.record.recordID
//                    self.database.fetch(withRecordID: ref ) { rec, error in
//                        guard let rec = rec else {return}
//    //                    for record in records {
//                            let reminder = Reminder(
//                                medName: record["medName"] as! String,
//                                intakeType: record["intakeType"] as! String,
//                                intakeTime: record["intakeTime"] as! Date,
//                                intakeAmount: record["intakeAmount"] as! Double,
//                                delay: record["delay"] as! Int,
//                                allowSnooze: (record["allowSnooze"] as! Int) != 0,
//                                notes: record["notes"] as! String
//                            )
//                            print("we got reminder /(reminder)")
//                            medRecordReminders.append(reminder)
//                            newReminders.append(reminder)
//                        }
//                    }
//            }

                
//            }
//                print("about to share the reminders after coralling from cloudkit")
//                print(medRecordReminders)
                let med = Med(
                    name: record["name"] as! String,
                    details: record["details"] as! String,
                    format: record["format"] as! String,
                    color: record["color"] as! Color?,
                    shape: record["shape"] as! [String],
                    engraving: record["engraving"] as! String,
                    dosage: record["dosage"] as! Double,
                    scheduled: ((record["scheduled"] as! Int) != 0),
//                    reminders: medRecordReminders.count == 0 ? [] : medRecordReminders,
//                    reminderRef: record["reminderRef"] == nil ? [] : (record["reminderRef"] as! [CKRecord.Reference]),
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
//                    self.reminderData = newReminders
                    print("we got the data!: \(medData)")
//                    print("we got the data for reminders: \(reminderData)")
//                    self.tableView.reloadData()
                } else {
                    print("we got an error in the completion block")
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of medications; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                    print("please try again: \(error!.localizedDescription)")
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                }
            }
        }
        database.add(medOperation)
    }
    
    
//    func getAllTheData(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
//        var newMeds = [Med]()
//        var newReminders = [Reminder]()
////        var newHistory = [History]()
//
//        let predicate = NSPredicate(value: true)
//
//        let medQuery = CKQuery(recordType: "Med", predicate: predicate)
//
//        medQuery.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
//
//        let medOperation = CKQueryOperation(query: medQuery)
//        medOperation.desiredKeys = ["name", "details", "format", "color", "shape", "engraving", "dosage", "scheduled", "reminders", "reminderRef", "history"]
////        let reminderOperation = CKQueryOperation(query: reminderQuery)
//
//        medOperation.recordFetchedBlock = { record in
////            let reminderRef = record["reminderRef"]
//            let currentMedRecordID = record.recordID
//            var medRecordReminders: [Reminder] = []
//
//            let reminderPredicate = NSPredicate(format: "medReference CONTAINS %@", currentMedRecordID)
//            let reminderQuery = CKQuery(recordType: "Reminder", predicate: reminderPredicate)
//            reminderQuery.sortDescriptors = [NSSortDescriptor(key: "intakeTime", ascending: true)]
//
//            self.database.perform(reminderQuery, inZoneWith: nil) { [unowned self] records, error in
//                if let error = error {
//                    print("hello from inside reminderQuery in getalldata")
//                    print(error.localizedDescription)
//                } else {
//                    print("hello renee were inside medoperation inside getalldata in the things are going okay place")
//                    guard let records = records else {return}
//                    for record in records {
//                        let reminder = Reminder(
//                            medName: record["medName"] as! String,
//                            intakeType: record["intakeType"] as! String,
//                            intakeTime: record["intakeTime"] as! Date,
//                            intakeAmount: record["intakeAmount"] as! Double,
//                            delay: record["delay"] as! Int,
//                            allowSnooze: (record["allowSnooze"] as! Int) != 0,
//                            notes: record["notes"] as! String? ?? ""
//                        )
//                        print(reminder)
//                        print("we got reminder \(reminder)")
//                        medRecordReminders.append(reminder)
//                        newReminders.append(reminder)
//                    }
//                    print("medRecordReminders incoming:")
//                    print(medRecordReminders)
//                    print("newReminders incoming")
//                    print(newReminders)
//                }
//
//            }
//
////            if let reminds = reminderRef {
////                for ref in reminds {
////                    let refRecordID = ref.record.recordID
////                    self.database.fetch(withRecordID: ref ) { rec, error in
////                        guard let rec = rec else {return}
////    //                    for record in records {
////                            let reminder = Reminder(
////                                medName: record["medName"] as! String,
////                                intakeType: record["intakeType"] as! String,
////                                intakeTime: record["intakeTime"] as! Date,
////                                intakeAmount: record["intakeAmount"] as! Double,
////                                delay: record["delay"] as! Int,
////                                allowSnooze: (record["allowSnooze"] as! Int) != 0,
////                                notes: record["notes"] as! String
////                            )
////                            print("we got reminder /(reminder)")
////                            medRecordReminders.append(reminder)
////                            newReminders.append(reminder)
////                        }
////                    }
////            }
//
//
////            }
//                print("about to share the reminders after coralling from cloudkit")
//                print(medRecordReminders)
//                let med = Med(
//                    name: record["name"] as! String,
//                    details: record["details"] as! String,
//                    format: record["format"] as! String,
//                    color: record["color"] as! Color?,
//                    shape: record["shape"] as! [String],
//                    engraving: record["engraving"] as! String,
//                    dosage: record["dosage"] as! Double,
//                    scheduled: ((record["scheduled"] as! Int) != 0),
//                    reminders: medRecordReminders.count == 0 ? [] : medRecordReminders,
////                    reminderRef: record["reminderRef"] == nil ? [] : (record["reminderRef"] as! [CKRecord.Reference]),
//                    history: record["history"] == nil ? [] : (record["history"] as! [History])
//                )
//                print(med)
//                newMeds.append(med)
//        }
//
//        medOperation.queryCompletionBlock = { [unowned self] (cursor, error) in
//            DispatchQueue.main.async {
//                if error == nil {
//                    print("newMeds before updating medData: \(newMeds)")
//                    self.medData = newMeds
//                    self.reminderData = newReminders
//                    print("we got the data!: \(medData)")
//                    print("we got the data for reminders: \(reminderData)")
////                    self.tableView.reloadData()
//                } else {
//                    print("we got an error in the completion block")
//                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of medications; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
//                    print("please try again: \(error!.localizedDescription)")
//                    ac.addAction(UIAlertAction(title: "OK", style: .default))
//                }
//            }
//        }
//        database.add(medOperation)
//    }
//
    
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
            let predicate = NSPredicate(format: "name = %@", med.name)
            let query = CKQuery(recordType: "Med", predicate: predicate)
//            var recordID = CKRecord.ID()
            
            database.perform(query, inZoneWith: nil) { records, error in
                guard let records = records else { return }
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

                saveOperation.perRecordCompletionBlock = { record, error in
                    if let error = error {
                        self.reportError(error)
                    }
//                    medData = self.getData()
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
                self.getData()
                self.database.add(saveOperation)
            }
        }
            
            
            
            

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
    
    
    
    
    
    
    func getAllReminderData(completionHandler:  ((Result<Void, Error>) -> Void)? = nil) {
//    func getReminderData(completionHandler: @escaping (Result<Void, Error>) -> ()) {
        var newReminders = [Reminder]()

        let predicate = NSPredicate(value: true)
        
        let reminderQuery = CKQuery(recordType: "Reminder", predicate: predicate)

        reminderQuery.sortDescriptors = [NSSortDescriptor(key: "intakeTime", ascending: true)]
        
        let reminderOperation = CKQueryOperation(query: reminderQuery)
        
        reminderOperation.recordFetchedBlock = { record in
            DispatchQueue.main.async {
                let reminder = Reminder(
                    medName: record["medName"] as! String,
                    intakeType: record["intakeType"] as! String,
                    intakeTime: record["intakeTime"] as! Date,
                    intakeAmount: record["intakeAmount"] as! Double,
                    delay: record["delay"] as! Int,
                    allowSnooze: (record["allowSnooze"] as! Int) != 0,
                    notes: record["notes"] as! String
                )
                print(reminder)
                newReminders.append(reminder)
            }

        }
        
        reminderOperation.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("we got an error in the completion block")
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of reminders; please try again: \(error.localizedDescription)", preferredStyle: .alert)
                    print("please try again: \(error.localizedDescription)")
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
//                    completionHandler(.failure())
                } else {
                    print("newReminders before updating reminderData: \(newReminders)")
                    self.reminderData = newReminders
                    self.getData()
                    print("we got the reminder data!: cloudkit\(reminderData)")
//                    completionHandler(.success())
//                    return
                }
                
//                if error == nil {
//                    print("newReminders before updating reminderData: \(newReminders)")
//                    self.reminderData = newReminders
//                    print("we got the reminder data!: cloudkit\(reminderData)")
//                    completionHandler(.success(reminderData))
//                    self.getData()
//                    return
////                    self.tableView.reloadData()
//                } else {
//                    print("we got an error in the completion block")
//                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of reminders; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
//                    print("please try again: \(error!.localizedDescription)")
//                    ac.addAction(UIAlertAction(title: "OK", style: .default))
////                    completionHandler(.failure())
//                }
            }
        }
        database.add(reminderOperation)
//        getData()

    }
    
    /// Fetches the last person record and updates the published `lastPerson` property in the VM.
    /// - Parameter completionHandler: An optional handler to process completion `success` or `failure`.
    func getData(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
        // Here, we will use the convenience "fetch" method on CKDatabase, instead of
        // CKFetchRecordsOperation, which is more flexible but also more complex.
//        var newMeds: [Med] = []
//        getReminderData()
        var newMeds = [Med]()

        let predicate = NSPredicate(value: true)
        
        let medQuery = CKQuery(recordType: "Med", predicate: predicate)

        medQuery.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let medOperation = CKQueryOperation(query: medQuery)
        medOperation.desiredKeys = ["name", "details", "format", "color", "shape", "engraving", "dosage", "scheduled", "reminders", "reminderRef", "history"]
        
        medOperation.recordFetchedBlock = { record in
            let reminders = self.reminderData.filter { $0.medName == record["name"] }
            
//            let reminders = record["reminderRef"].count > 0 ? [] as __CKRecordObjCValue : record["reminderRef"]
//
//            if reminders != [] {
//                for reminder in reminders {
//                    let fetchReminders =
//
//
//                }
//
//            }
                let med = Med(
                    name: record["name"] as! String,
                    details: record["details"] as! String,
                    format: record["format"] as! String,
                    color: record["color"] as! Color?,
                    shape: record["shape"] as! [String],
                    engraving: record["engraving"] as! String,
                    dosage: record["dosage"] as! Double,
                    scheduled: ((record["scheduled"] as! Int) != 0),
                    reminders: reminders.count == 0 ? [] : reminders,
//                    reminderRef: record["reminderRef"] == nil ? [] : (record["reminderRef"] as! [CKRecord.Reference]),
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
                    print("we got an error in the completion block")
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of medications; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
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
        
        
        database.delete(withRecordID: recordID) { (deletedRecordID, error) in
            if let error = error {
                completionHandler(.failure(error))
                debugPrint("Error deleting med: \(error)")
            } else {
                DispatchQueue.main.async {
                    let index = self.medData.firstIndex(where: { $0.name == name })
//                    print("here's the index: \(index)")
                    self.medData.remove(at: index!)
                    print("record deleted!")
                    completionHandler(.success(()))
                }

            }
        }
        
//        self.getData()
        
//         let deleteOperation = CKModifyRecordsOperation(recordIDsToDelete: [recordID])
//
//         deleteOperation.modifyRecordsCompletionBlock = { _, _, error in
//             if let error = error {
//                 completionHandler(.failure(error))
//                 debugPrint("Error deleting med: \(error)")
//             } else {
//                 DispatchQueue.main.async {
//                    let currentRecord = self.medData
//
//                    let index = self.medData.firstIndex(where: { $0.name == name })
//                    self.medData.remove(at: index)
//                    print("here are the meds after the supposed deletion: \(self.medData)")
//                     completionHandler(.success(()))
//                 }
//             }
//         }
//         database.add(deleteOperation)
     }

    
    
    // MARK: - Helpers
    
    
    
/// Fetches the last reminder record
/// - Parameter completionHandler: An optional handler to process completion `success` or `failure`.
    func getLastReminderOrCallCreateReminder(med: Med, reminder: Reminder, name: String, completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
//        var predicate: NSPredicate = nil
        let predicate = NSPredicate(format: "medName =%@", name)
        
        let reminderQuery = CKQuery(recordType: "Reminder", predicate: predicate)
        var recordID = CKRecord.ID()
        
//        let reminderOperation = CKQueryOperation(query: reminderQuery)
        
        database.perform(reminderQuery, inZoneWith: nil) { records, error in
            guard let records = records else { return }
            //                self.createReminderRecord(med: med, reminder: reminder)
               
            recordID = records[0].recordID

//            if records[0] != nil {
//            }
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
    
    func createReminderRecord(med: Med, reminder: Reminder) {
        var medRecord = CKRecord(recordType: "Med")
        print("hellow this is the name we are getting: \(med)")
        let predicate = NSPredicate(format: "name = %@", reminder.medName)
        
        let medQuery = CKQuery(recordType: "Med", predicate: predicate)
//        var medRecordID = CKRecord.ID()
        
        database.perform(medQuery, inZoneWith: nil) { records, error in
            guard let records = records else { return }
            medRecord = records[0]
            print("here is medrecord inside of database.perform(): \(medRecord)")
            let medRecordID = records[0].recordID
            
            print("this is medRecordID: \(medRecordID)")
            let referenceToMedRecord = CKRecord.Reference(recordID: medRecordID, action: .deleteSelf)
    //        var recordID = CKRecord.ID(rec)
            let newReminder = CKRecord(recordType: "Reminder")
            newReminder["medName"] = reminder.medName
            newReminder["intakeType"] = reminder.intakeType
            newReminder["intakeTime"] = reminder.intakeTime
            newReminder["intakeAmount"] = reminder.intakeAmount
            newReminder["delay"] = reminder.delay
            newReminder["allowSnooze"] = reminder.allowSnooze
            newReminder["notes"] = reminder.notes
            newReminder["medReference"] = referenceToMedRecord
//            newReminder.setParent(medRecord)
            
            let referenceToReminder = CKRecord.Reference(recordID: newReminder.recordID, action: .none)
            print("here is medRecord before updating with reference: \(medRecord)")
    //        medRecord["reminders"] = [reminder]
            medRecord = CKRecord(recordType: "Med", recordID: medRecordID)
            
            medRecord["name"] = med.name
            medRecord["details"] = "We've changed this one and here's the proof"
            medRecord["format"] = med.format
    //        medRecord["color"] = (UIColor(med.color!) as! __CKRecordObjCValue)
            medRecord["shape"] = med.shape
            medRecord["engraving"] = med.engraving
            medRecord["dosage"] = med.dosage
            medRecord["scheduled"] = med.scheduled == true ? 1 : 0
//            medRecord["reminders"] = med.reminders as __CKRecordObjCValue
//            newMeds.append(newMed)
            medRecord["reminderRef"] = [referenceToReminder]

            let saveReminderOperation = CKModifyRecordsOperation(recordsToSave: [newReminder, medRecord])
            saveReminderOperation.savePolicy = .allKeys

            saveReminderOperation.perRecordCompletionBlock = { record, error in
                if let error = error {
                    self.reportError(error)
                }
            }
            

            saveReminderOperation.modifyRecordsCompletionBlock = { _, _, error in
                if let error = error {
                    self.reportError(error)
    //                completionHandler?(.failure(error))
                } else {
                    print(newReminder)
                    print("we added a new reminder record!")
                    // If a completion was supplied, like during tests, call it back now.
    //                completionHandler?(.success(()))
                }
            }
            
//            saveMedReferenceOperation.modifyRecordsCompletionBlock = { _, _, error in
//                if let error = error {
//                    self.reportError(error)
//    //                completionHandler?(.failure(error))
//                } else {
//                    print(medRecord)
//                    print("we updated the med record!")
//                    // If a completion was supplied, like during tests, call it back now.
//    //                completionHandler?(.success(()))
//                }
//            }

            self.database.add(saveReminderOperation)
//            self.database.add(saveMedReferenceOperation)
            self.getData()
            
        }
        
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

//
//  RecordSyncer.swift
//  MedsMinder
//
//  Created by Renee Berger on 12/28/21.
//

import CloudKit
import Foundation
import os.log

actor RecordSyncer {
  // MARK: Supporting Structs
  struct PendingAction<T> {
    enum Status {
      case notStarted
      case inProgress
    }
    var target: T
    var status: Status = .notStarted
  }

  // MARK: CloudKit Config
  var database: CKDatabase
  var zoneID: CKRecordZone.ID
  var zone: CKRecordZone?
  private var subscription: CKSubscription?
  private let subscriptionID = "changes-subscription-id"

  // MARK: Filenames for Local Store
  private let syncedRecordsFilename = "syncedRecords.db"
  private let pendingAdditionsFilename = "pendingAdditions.db"
  private let pendingDeletionsFilename = "pendingDeletions.db"

  // MARK: Record Processor
  var recordProcessor: RecordProcessor

  // MARK: Internal State
  var lastChangeToken: CKServerChangeToken?
  var syncedRecords: [CKRecord.ID: CKRecord] = [:]
  var pendingAdditions: [PendingAction<CKRecord>] = []
  var pendingDeletions: [PendingAction<CKRecord.ID>] = []

  // Provides a view of the current valid records, ultimately this is what is shared to the record
  // processor and the rest of the app
  var currentRecords: [CKRecord.ID: CKRecord] {
    var allRecords: [CKRecord.ID: CKRecord] = syncedRecords
    for recordAction in pendingAdditions {
      allRecords[recordAction.target.recordID] = recordAction.target
    }

    return allRecords.filter { recordID, record in
      !pendingDeletions.contains(where: { $0.target == recordID })
    }
  }

  init(database: CKDatabase, recordProcessor: RecordProcessor, zoneID: CKRecordZone.ID) {
    self.database = database
    self.recordProcessor = recordProcessor
    self.zoneID = zoneID

    // TODO: Move this to an async method and call before fetch and sync in the CloudBackedModel -- but only do this once!
    // Load saved data but don't sync since we don't want to block too much on init.. probably
    // shouldn't even be doing this much.
    self.loadLastChangeToken()
    self.loadLocalCache()
  }

  // MARK: Add and Delete Records

  func add(record: CKRecord) async {
    pendingAdditions.append(PendingAction(target: record))
    recordProcessor.processRecords(currentRecords: currentRecords)

    Task {
      try await syncPendingRecords()
    }
  }

  func delete<T: Identifiable>(objects: [T]) async {
    for object in objects {
      let recordID: CKRecord.ID? = self.recordProcessor.processedRecordData.uuidToRecord[
        object.id as! UUID]
      if recordID != nil {
        await self.deleteRecord(recordID: recordID!)
      } else {
        os_log("Trying to delete an object with no ID in the syncer")
      }
    }
  }

  func deleteRecord(recordID: CKRecord.ID) async {
    let localAdditions = pendingAdditions.filter({ $0.status == .notStarted })
    if localAdditions.contains(where: { $0.target.recordID == recordID }) {
      pendingAdditions.removeAll(where: { $0.target.recordID == recordID })
      recordProcessor.processRecords(currentRecords: currentRecords)
      return
    }

    pendingDeletions.append(PendingAction(target: recordID))
    recordProcessor.processRecords(currentRecords: currentRecords)

    Task {
      try await syncPendingRecords()
    }
  }

  // MARK: Sync and Fetch

  // TODO: Schedule retry on fail
  func syncPendingRecords() async throws {
    var recordResults: [Result<CKRecord, Error>]
    var deleteResults: [CKRecord.ID: Result<Void, Error>]
    // Do this book-keeping here since the function is re-entrant, womp womp
    let currentAdditions = pendingAdditions.filter({ $0.status == .notStarted }).map({ $0.target })
    let currentDeletions = pendingDeletions.filter({ $0.status == .notStarted }).map({ $0.target })

    // If there is nothing to do then do nothing.
    if currentAdditions.count == 0 && currentDeletions.count == 0 {
      return
    }

    // Update the current arrays to note that tasks are in progressed so they don't get picked up
    // twice
    pendingAdditions = pendingAdditions.map({
      PendingAction(target: $0.target, status: .inProgress)
    })
    pendingDeletions = pendingDeletions.map({
      PendingAction(target: $0.target, status: .inProgress)
    })

    // Save local cache before starting the sync
    saveLocalCache()

    do {
      let (saveResults, deleteResultsMap) = try await database.modifyRecords(
        saving: currentAdditions,
        deleting: currentDeletions,
        savePolicy: .changedKeys)
      recordResults = Array(saveResults.values)
      deleteResults = deleteResultsMap
    } catch let functionError {  // Handle per-function error
      ErrorReporter.reportCKError(functionError)

      // Delete anything from pendingAdditions that has been delteted after `await`
      pendingAdditions = pendingAdditions.filter({ !currentDeletions.contains($0.target.recordID) })

      // Restore the pending items after a failure
      pendingAdditions = pendingAdditions.map({
        currentAdditions.contains($0.target)
          ? PendingAction(target: $0.target, status: .notStarted) : $0
      })
      pendingDeletions = pendingDeletions.map({
        currentDeletions.contains($0.target)
          ? PendingAction(target: $0.target, status: .notStarted) : $0
      })

      // Write the new state to disk before throwing, nothing to process since nothing really changed.
      throw functionError
    }

    for recordResult in recordResults {
      switch recordResult {
      case .success(let record):
        let recordID = record.recordID
        self.pendingAdditions.removeAll(where: { recordID == $0.target.recordID })
        self.syncedRecords[recordID] = record

      case .failure(let recordError):  // Handle per-record error
        ErrorReporter.reportCKError(recordError)
      //TODO: Handle per record errors
      }
    }

    for (recordID, result) in deleteResults {
      switch result {
      case .success:
        self.syncedRecords.removeValue(forKey: recordID)
        self.pendingDeletions.removeAll(where: { $0.target == recordID })
      case .failure(let recordError):  // Handle per-record error
        ErrorReporter.reportCKError(recordError)
      //TODO: Handle per record errors
      }
    }

    self.recordProcessor.processRecords(currentRecords: currentRecords)
    saveLocalCache()
  }

  // Fetches changes since last sync or all the records if `changeToken` is nil
  func fetchChanges() async throws {
    do {
      /// `recordZoneChanges` can return multiple consecutive changesets before completing, so
      /// we use a loop to process multiple results if needed, indicated by the `moreComing` flag.
      var moreComing = true

      try await createZoneIfNeeded()
      try await createSubscriptionIfNeeded()

      while moreComing {
        /// Fetch changeset for the last known change token.
        let changes = try await database.recordZoneChanges(
          inZoneWith: zoneID, since: lastChangeToken)

        /// Convert changes to `CKRecord` objects and deleted IDs. This is form Apple code and explictly drops errors, which
        /// we should look at and do something for
        let changedRecords = changes.modificationResultsByID.compactMapValues {
          try? $0.get().record
        }
        let deletedRecordIDs = changes.deletions.map { $0.recordID }

        for deletedID in deletedRecordIDs {
          syncedRecords.removeValue(forKey: deletedID)
        }
        syncedRecords.merge(changedRecords) { _, new in new }
        recordProcessor.processRecords(currentRecords: currentRecords)

        /// Save our new change token representing this point in time.
        lastChangeToken = changes.changeToken

        /// If there are more changes coming, we need to repeat this process with the new token.
        /// This is indicated by the returned changeset `moreComing` flag.
        moreComing = changes.moreComing
      }
    } catch {
      guard let ckerror = error as? CKError else {
        os_log("Not a CKError: \(error.localizedDescription)")
        return
      }

      if ckerror.code == .changeTokenExpired {
        self.lastChangeToken = nil
        saveChangeToken(nil)
        try await fetchChanges()
      } else {
        ErrorReporter.reportCKError(error)
        // Give callers a chance to handle this error as they like
        saveLocalCache()
        throw error
      }
    }

    saveLocalCache()
  }

  // MARK: CloudKit Zone and Subscription Handling

  // https://developer.apple.com/documentation/cloudkit/ckrecordzone/1515102-init says to use zone
  // objects fetched from the server once they already exist. We don't really use it though so
  // we probably don't need all this code here. We could likely vastly simplify these two methods.
  func fetchZoneObjectIfPresent() async throws {
    do {
      if zone == nil {
        let recordZones = try await database.allRecordZones()
        if recordZones.contains(where: { $0.zoneID == self.zoneID }) {
          zone = recordZones.first(where: { $0.zoneID == self.zoneID })
          return
        }
      }
    } catch {
      ErrorReporter.reportCKError(error)
      throw error
    }
  }

  /// Creates the custom zone defined by the `zone` property if needed.
  func createZoneIfNeeded() async throws {
    do {
      if zone == nil {
        try await fetchZoneObjectIfPresent()

        if zone == nil {
          let newZone = CKRecordZone(zoneID: zoneID)
          let _ = try await database.modifyRecordZones(saving: [newZone], deleting: [])
          try await fetchZoneObjectIfPresent()
        }
      }
    } catch {
      ErrorReporter.reportCKError(error)
      throw error
    }
  }

  // This is based on the Apple sampel code, but doesn't really do much in the way of error handling.
  // There are likely improvements that can be made here.
  func createSubscriptionIfNeeded() async throws {
    // First check if the subscription has already been created.
    // If a subscription is returned, we don't need to create one.
    if subscription == nil {
      let foundSubscription = try? await database.subscription(for: subscriptionID)
      guard foundSubscription == nil else {
        subscription = foundSubscription!
        return
      }

      // No subscription created yet, so create one here, reporting and passing along any errors.
      let subscription = CKRecordZoneSubscription(zoneID: zoneID, subscriptionID: subscriptionID)
      let notificationInfo = CKSubscription.NotificationInfo()
      notificationInfo.shouldSendContentAvailable = true
      subscription.notificationInfo = notificationInfo

      _ = try await database.modifySubscriptions(saving: [subscription], deleting: [])
    }
  }

  // MARK: Local Cache Handling

  // this is form the internet https://stackoverflow.com/questions/54359022/saving-cloudkit-record-to-local-file-saves-all-fields-except-ckasset
  // the code is kind of awful all around. There is way too much duplication and we are using
  // synchronous APIs for the most part.

  private func localCacheURL(name: String) -> URL {
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let docsDirectoryURL = urls[0]
    let dirURL = docsDirectoryURL.appendingPathComponent(name)
    return dirURL
  }

  private func loadLocalCache() {
    var dirURL = localCacheURL(name: self.syncedRecordsFilename)

    var records: [CKRecord.ID: CKRecord] = [:]
    if FileManager.default.fileExists(atPath: dirURL.path) {
      do {
        let data = try Data(contentsOf: dirURL)
        if let theRecords: [CKRecord.ID: CKRecord] = NSKeyedUnarchiver.unarchiveObject(with: data)
          as? [CKRecord.ID: CKRecord]
        {
          records = theRecords
        }
      } catch {
        print("could not retrieve records from documents directory")
      }
    }
    self.syncedRecords = records

    dirURL = localCacheURL(name: self.pendingDeletionsFilename)
    var pendingDeletions: [CKRecord.ID] = []
    if FileManager.default.fileExists(atPath: dirURL.path) {
      do {
        let data = try Data(contentsOf: dirURL)
        if let theRecords: [CKRecord.ID] = NSKeyedUnarchiver.unarchiveObject(with: data)
          as? [CKRecord.ID]
        {
          pendingDeletions = theRecords
        }
      } catch {
        print("could not retrieve records from documents directory")
      }
    }
    self.pendingDeletions = pendingDeletions.map { PendingAction(target: $0) }

    dirURL = localCacheURL(name: self.pendingAdditionsFilename)
    var pendingAdditions: [CKRecord] = []
    if FileManager.default.fileExists(atPath: dirURL.path) {
      do {
        let data = try Data(contentsOf: dirURL)
        if let theRecords: [CKRecord] = NSKeyedUnarchiver.unarchiveObject(with: data)
          as? [CKRecord]
        {
          pendingAdditions = theRecords
        }
      } catch {
        print("could not retrieve records from documents directory")
      }
    }
    self.pendingAdditions = pendingAdditions.map { PendingAction(target: $0) }

    recordProcessor.processRecords(currentRecords: currentRecords)
  }

  private func saveLocalCache() {
    do {
      let syncedRecordsURL = localCacheURL(name: syncedRecordsFilename)
      let syncedRecrodsData: Data = try NSKeyedArchiver.archivedData(
        withRootObject: self.syncedRecords, requiringSecureCoding: true)

      let pendingDeletionsURL = localCacheURL(name: pendingDeletionsFilename)
      let pendingDeletionsData: Data = try NSKeyedArchiver.archivedData(
        withRootObject: self.pendingDeletions.map({ $0.target }), requiringSecureCoding: true)

      let pendingAdditionsURL = localCacheURL(name: pendingAdditionsFilename)
      let pendingAdditionsData: Data = try NSKeyedArchiver.archivedData(
        withRootObject: self.pendingAdditions.map({ $0.target }), requiringSecureCoding: true)

      if self.lastChangeToken != nil {
        self.saveChangeToken(self.lastChangeToken!)
      }

      // TODO: I really don't like this, this should be managed better as a task we can keep track
      // of and make sure not to start one before the other finishes.
      DispatchQueue.global(qos: .background).async { [self] in
        do {
          try syncedRecrodsData.write(to: syncedRecordsURL, options: .atomic)
          try pendingDeletionsData.write(to: pendingDeletionsURL, options: .atomic)
          try pendingAdditionsData.write(to: pendingAdditionsURL, options: .atomic)
        } catch {
          print("could not save")
          self.saveChangeToken(nil)  // nil out the save token so we are forced to pull new data
        }
      }
    } catch {
      print("could not save records to documents directory")
    }
  }

  // MARK: Change Token Management

  // TODO: Copied from Apple but it's bad practice to use a raw string here, it is also possible that
  //       this will succeed or fail but our other data saving won't.
  private func loadLastChangeToken() {
    guard let data = UserDefaults.standard.data(forKey: "lastChangeToken"),
      let token = try? NSKeyedUnarchiver.unarchivedObject(
        ofClass: CKServerChangeToken.self, from: data)
    else {
      return
    }

    lastChangeToken = token
  }

  private nonisolated func saveChangeToken(_ token: CKServerChangeToken?) {
    if token == nil {
      UserDefaults.standard.removeObject(forKey: "lastChangeToken")
      return
    }
    let tokenData = try! NSKeyedArchiver.archivedData(
      withRootObject: token!, requiringSecureCoding: true)
    UserDefaults.standard.set(tokenData, forKey: "lastChangeToken")
  }
}

//
//  ErrorReporter.swift
//  MedsMinder
//
//  Created by Renee Berger on 12/28/21.
//

import CloudKit
import Foundation
import os.log

// This is a utility function for logging CloudKit errors, it was copied from one of Apple's sample
// projects.
struct ErrorReporter {
  static func reportCKError(_ error: Error) {
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
          reportCKError(error)
        }
      }

    // This switch could explicitly handle as many specific errors as needed, for example:
    case .unknownItem:
      os_log("CKError: Record not found.")

    case .notAuthenticated:
      os_log(
        "CKError: An iCloud account must be signed in on device or Simulator to write to a PrivateDB."
      )

    case .permissionFailure:
      os_log("CKError: An iCloud account permission failure occured.")

    case .networkUnavailable:
      os_log("CKError: The network is unavailable.")

    default:
      os_log("CKError: \(error.localizedDescription)")
    }
  }
}

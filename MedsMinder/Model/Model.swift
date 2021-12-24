//
//  Model.swift
//  MedsMinder
//
//  Created by Renee Berger on 12/30/21.
//

import Foundation
import SwiftUI

// Base model class. This is intended to be subclassed and have all of its methods overriden. This
// allows us to use `Model` everywhere and switch out the preivew vs CloudKit model for previews or
// for local debug builds.
@MainActor class Model: ObservableObject {
  @Published var viewModel: ViewModel = ViewModel()

  func add(medication: Medication) {}
  func add(reminder: Reminder) {}
  func add(history: History) {}

  func delete(reminders: [Reminder]) {}
  func delete(medications: [Medication]) {}
  func delete(history: [History]) {}

  func startSync() async throws {}
}

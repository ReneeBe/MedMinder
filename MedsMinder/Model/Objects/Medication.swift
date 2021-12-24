//
//  Med.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/1/21.
//

import CloudKit
import Foundation
import SwiftUI

struct Medication: Identifiable, Codable, Hashable, Comparable {
  let id: UUID
  var name: String
  var details: String
  var format: Format
  var color: [Color?]
  var shape: [String]  // TODO: Make this an enum
  var engraving: String
  var dosage: Double
  var history: [History]

  init(
    id: UUID = UUID(), name: String, details: String, format: Format, color: [Color?],
    shape: [String], engraving: String, dosage: Double,
    reminders: [Reminder] = [],
    history: [History] = []
  ) {
    self.id = id
    self.name = name
    self.details = details
    self.format = format
    self.color = color
    self.shape = shape
    self.engraving = engraving
    self.dosage = dosage
    self.history = history
  }

  // Do our best to have a stable (the same every time) sort here so that calling
  // .sorted does something reasonable.
  static func < (lhs: Medication, rhs: Medication) -> Bool {
    if lhs.name == rhs.name {
      return lhs.id.uuidString < rhs.id.uuidString
    }
    return lhs.name < rhs.name
  }

  enum Format: String, Codable, Identifiable, CaseIterable {
    var id: String { self.rawValue }

    case tablet
    case capsule
    case liquid

    var name: String {
      switch self {
      case .tablet:
        return "Tablet"
      case .capsule:
        return "Capsule"
      case .liquid:
        return "Liquid"
      }
    }
  }
}

// MARK: Preview Data

extension Medication {
  static var data: [Medication] =
    [
      //0
      Medication(
        name: "WhiteTablet", details: "Every Morning", format: .tablet, color: [.white],
        shape: ["circle.fill", "1"], engraving: "ABC", dosage: 1,
        history: []),
      //1
      Medication(
        name: "BlueHalfTablet", details: "Taken 2 Hours Ago", format: .tablet,
        color: [.blue],
        shape: ["diamond.fill", "2"], engraving: "XYZ", dosage: 0.5,
        history: []),
      //2
      Medication(
        name: "YellowPinkCapsule", details: "3 Times A Day", format: .capsule,
        color: [.yellow, .pink],
        shape: ["capsule.lefthalf.filled", "3"], engraving: "123", dosage: 1,
        history: []),
      //3
      Medication(
        name: "PurpleWhiteHalfCapsule", details: "3 Times A Day", format: .capsule,
        color: [.purple, .white],
        shape: ["capsule.lefthalf.filled", "3"], engraving: "123", dosage: 0.5,
        history: []),
      //4
      Medication(
        name: "OrangeLiquidHalfRemindoxin", details: "Taken 2 Hours Ago", format: .liquid,
        color: [.orange],
        shape: ["circle.fill", "2"], engraving: "", dosage: 0.5,
        history: []),
      //5
      Medication(
        name: "GreenLiquidRemindoxin", details: "Taken 2 Hours Ago", format: .liquid,
        color: [.green],
        shape: ["circle.fill", "2"], engraving: "", dosage: 1,
        history: []),
    ]
}

// MARK: Data Extension

// TODO: Probably remove this? Not clear how much value this is adding.
extension Medication {
  struct Data {
    var name: String = ""
    var details: String = ""
    var format: Format = .tablet
    var color: [Color?] = [Color(.systemPink)]
    var shape: [String] = [""]
    var engraving: String = ""
    var dosage: Double = 0.00
    var history: [History] = []
  }
  var data: Data {
    return Data(
      name: name, details: details, format: format, color: color, shape: shape,
      engraving: engraving, dosage: Double(dosage),
      history: history)
  }
  mutating func update(from data: Data) {
    name = data.name
    details = data.details
    format = data.format
    color = data.color
    shape = data.shape
    engraving = data.engraving
    dosage = Double(data.dosage)
    history = data.history
  }
}

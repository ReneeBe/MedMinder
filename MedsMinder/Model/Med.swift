//
//  Med.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/1/21.
//

import Foundation
import SwiftUI
import CloudKit

struct Med: Identifiable, Codable {
    let id: UUID
    var name: String
    var details: String
    var format: String
    var color: Color?
    var shape: [String]
    var engraving: String
    var dosage: Double
    var scheduled: Bool?
    var reminders: [Reminder]
    var history: [History]
    
    init(id: UUID = UUID(), name: String, details: String, format: String, color: Color?, shape: [String], engraving: String, dosage: Double, scheduled: Bool, reminders: [Reminder] = [], history: [History] = []
    ) {
        self.id = id
        self.name = name
        self.details = details
        self.format = format
        self.color = color
        self.shape = shape
        self.engraving = engraving
        self.dosage = dosage
        self.scheduled = scheduled
        self.reminders = reminders
        self.history = history
    }
}

extension Med {
    static var data: [Med] {
        [
            Med( name: "Medication", details: "Every Morning", format: "tablet", color: .white, shape: ["circle.fill", "1"], engraving: "ABC", dosage: 1, scheduled: true, reminders: [], history: []),
            Med( name: "Medication", details: "3 Times A Day", format: "tablet", color: Color(.systemGreen), shape: ["circle.fill", "3"], engraving: "123", dosage: 1, scheduled: true, reminders: [], history: []),
            Med( name: "1/2 Medication", details: "Taken 2 Hours Ago", format: "tablet", color: .white, shape: ["circle.fill", "2"], engraving: "XYZ", dosage: 0.5, scheduled: false, reminders: [], history: [])
        ]
    }
}

extension Med {
    struct Data {
        var name: String = ""
        var details: String = ""
        var format: String = ""
        var color: Color? = Color(.systemPink)
        var shape: [String] = [""]
        var engraving: String = ""
        var dosage: Double = 0.00
        var scheduled: Bool? = false
        var reminders: [Reminder] = []
        var history: [History] = []
    }
    var data: Data {
        return Data(name: name, details: details, format: format, color: color, shape: shape, engraving: engraving, dosage: Double(dosage), scheduled: scheduled, reminders: reminders, history: history)
    }
    mutating func update(from data: Data) {
        name = data.name
        details = data.details
        format = data.format
        color = data.color
        shape = data.shape
        engraving = data.engraving
        dosage = Double(data.dosage)
        scheduled = data.scheduled
        reminders = data.reminders
        history = data.history
    }
}



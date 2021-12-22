//
//  Reminder.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/20/21.
//

import Foundation
import SwiftUI


struct Reminder: Identifiable, Codable, Hashable  {
    let id: UUID
    var medName: String
    var intakeType: String
    var intakeTime: Date
    var intakeAmount: Double
    var delay: Int
    var allowSnooze: Bool
    var notes: String

    
    init(id: UUID = UUID(), medName: String, intakeType: String, intakeTime: Date, intakeAmount: Double, delay: Int, allowSnooze: Bool, notes: String ) {
        self.id = id
        self.medName = medName
        self.intakeType = intakeType
        self.intakeTime = intakeTime
        self.intakeAmount = intakeAmount
        self.delay = delay
        self.allowSnooze = allowSnooze
        self.notes = notes
    }
}

extension Reminder {
    struct Data {
        var medName: String = ""
        var intakeType: String = ""
        var intakeTime: Date = Date(     )
        var intakeAmount: Double = 0.00
        var delay: Int = 300
        var allowSnooze: Bool = false
        var notes: String = ""
    }

    var data: Data {
        return Data(medName: medName, intakeType: intakeType, intakeTime: intakeTime, intakeAmount: Double(intakeAmount), delay: Int(delay), allowSnooze: allowSnooze, notes: notes)
    }
    mutating func update(from data: Data) {
        medName = data.medName
        intakeType = data.intakeType
        intakeTime = data.intakeTime
        intakeAmount = Double(data.intakeAmount)
        delay = Int(data.delay)
        allowSnooze = data.allowSnooze
        notes = data.notes
    }
}

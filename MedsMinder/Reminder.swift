//
//  Reminder.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/20/21.
//

import Foundation
import SwiftUI

//let formatter = DateFormatter()
//formatter.timeStyle = .short
//let dateString = formatter.string(from: Date())


struct Reminder: Identifiable, Codable, Hashable  {
    let id: UUID
    var medName: String
    var intakeType: String
    var intakeTimes: [Date]
    var intakeAmount: Double
    var delay: Int
    var allowSnooze: Bool
    var notes: String

    
    init(id: UUID = UUID(), medName: String, intakeType: String, intakeTimes: [Date], intakeAmount: Double, delay: Int, allowSnooze: Bool, notes: String ) {
        self.id = id
        self.medName = medName
        self.intakeType = intakeType
        self.intakeTimes = intakeTimes
        self.intakeAmount = intakeAmount
        self.delay = delay
        self.allowSnooze = allowSnooze
        self.notes = notes
    }
}

//extension Reminder {
//    static var data: [Reminder] {
//        [
//            Reminder(medName: "Medication", intakeType: "Scheduled Intake", intakeTimes: ["10:40 AM", "6:30 PM"], intakeAmount: 1, delay: 180, allowSnooze: true, notes: "If your weight varies from yesterday by 5 lbs, take an extra half pill"),
//            Reminder(medName: "Medication", intakeType: "Scheduled Intake", intakeTimes: ["11:00 AM", "4:00 PM"], intakeAmount: 1, delay: 180, allowSnooze: false, notes: ""),
//            Reminder(medName: "1/2 Medication", intakeType: "On Demand", intakeTimes: ["7:00 AM", "1:00 PM", "5:00 PM"], intakeAmount: 0.5, delay: 0, allowSnooze: true, notes: "")
//        ]
//    }
//}
//
//extension Reminder {
//    struct Data {
//        var medName: String = ""
//        var intakeType: String = ""
//        var intakeTimes: [String] = [""]
//        var intakeAmount: Double = 0.00
//        var delay: Int = 300
//        var allowSnooze: Bool = false
//        var notes: String = ""
//    }
//
//    var data: Data {
//        return Data(medName: medName, intakeType: intakeType, intakeTimes: intakeTimes, intakeAmount: Double(intakeAmount), delay: Int(delay), allowSnooze: allowSnooze, notes: notes)
//    }
//    mutating func update(from data: Data) {
//        medName = data.medName
//        intakeType = data.intakeType
//        intakeTimes = data.intakeTimes
//        intakeAmount = Double(data.intakeAmount)
//        delay = Int(data.delay)
//        allowSnooze = data.allowSnooze
//        notes = data.notes
//    }
//}

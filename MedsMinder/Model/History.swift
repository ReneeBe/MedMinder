//
//  History.swift
//  MedsMinder
//
//  Created by Renee Berger on 10/4/21.
//

import Foundation

struct History: Identifiable, Codable {
    let id: UUID
    let date: Date
    var dosage: Double


    init(id: UUID = UUID(), date: Date = Date(), dosage: Double) {
        self.id = id
        self.date = date
        self.dosage = dosage
    }
}

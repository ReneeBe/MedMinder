//
//  Med.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/1/21.
//

import Foundation

struct Med: Identifiable {
    var id: UUID
    var name: String
    var details: String
    var frequencyInMinutes: Int
    var pillDesign: String
    
    init(id: UUID = UUID(), name: String, details: String, frequencyInMinutes: Int, pillDesign: String = "pink" ) {
        self.id = id
        self.name = name
        self.details = details
        self.frequencyInMinutes = frequencyInMinutes
        self.pillDesign = pillDesign
        
    }
}

extension Med {
    static var data: [Med] {
        [
            Med(name: "Medication", details: "Every Morning", frequencyInMinutes: 180),
            Med(name: "Medication", details: "3 Times A Day", frequencyInMinutes: 180),
            Med(name: "1/2 Medication", details: "Taken 2 Hours Ago", frequencyInMinutes: 0)
        ]
    }
}

extension Med {
    struct Data {
        var name: String = ""
        var details: String = ""
        var frequencyInMinutes: Int = 300
        var pillDesign: String = "pink"
    }
    var data: Data {
        return Data(name: name, details: details, frequencyInMinutes: Int(frequencyInMinutes), pillDesign: pillDesign)
    }
    mutating func update(from data: Data) {
        name = data.name
        details = data.details
        frequencyInMinutes = Int(data.frequencyInMinutes)
        pillDesign = data.pillDesign
    }
}

    

//var scheduledMeds: [Med] = [
//    Med(id = 1, name = "Medication", details = "Every Morning"),
//    Med(id = 2, name = "Medication", details = "3 Times A Day")
//]
//
//var onDemandMeds: [Med] = [
//    Med(id = 3, name = "1/2 Medication", details = "Taken 2 Hours Ago")
//]

//
//  MedsMinderApp.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/1/21.
//

import SwiftUI

@main
struct MedsMinderApp: App {
    @State private var medications: [Med] = Med.data
    var body: some Scene {
        WindowGroup {
            MainView( meds: $medications)
        }
    }
}

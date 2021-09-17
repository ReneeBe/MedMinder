//
//  MedsMinderApp.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/1/21.
//

import SwiftUI

@main
struct MedsMinderApp: App {
    @ObservedObject private var data = MedData()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainView(meds: $data.meds) {
                    data.save()
                }
                .navigationBarHidden(true)
            }
            .onAppear {
                data.load()
            }
        }
    }
}

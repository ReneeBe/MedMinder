//
//  ContentView.swift
//  MedsMinder
//
//  Created by Renee Berger on 10/25/21.
//

import CloudKit
import SwiftUI
import UserNotifications

struct ContentView: View {
  @EnvironmentObject var eventHandler: EventHandler
  var viewModel: ViewModel
  @Environment(\.scenePhase) private var scenePhase

  var body: some View {
    TabView {
      RemindersView(viewModel: viewModel)
        .tabItem {
          Label("Reminders", systemImage: "clock.fill").font(.title)
        }
      MedicationsNavBar(viewModel: viewModel)
        .tabItem {
          Label("Medications", systemImage: "pills.circle.fill").font(.largeTitle)
        }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      viewModel: ViewModel.data
    ).environmentObject(EventHandler(model: PreviewModel()))
  }
}

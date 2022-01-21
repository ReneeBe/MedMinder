//
//  MedsMinderApp.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/1/21.
//

import CloudKit
import SwiftUI
import UIKit
import UserNotifications

@main
struct MedsMinderApp: App {
  // This is a static instance that is only intended to be used in the app delegate below. In general
  // doing this is a bad idea, you should directly pass down your dependencies or
  // use @EnvironmentObject when you can and this makes it so there are implicit dependencies you
  // may need to preview or test a component. Keep this isolated just to this file.
  static var sharedModel: Model = CloudBackedModel()
  //    static var sharedModel: Model = PreviewModel() // -- uncomment this out and comment above for preview model
  @StateObject var model: Model = (MedsMinderApp.sharedModel)
  @StateObject var eventHandler: EventHandler
  @Environment(\.scenePhase) private var scenePhase

  /// We use an AppDelegate class to handle push notification registration and handling.
  @UIApplicationDelegateAdaptor(MedsMinderAppDelegate.self) private var appDelegate

  init() {
    // Init here since it depends on another ivar
    _eventHandler = StateObject(wrappedValue: EventHandler(model: MedsMinderApp.sharedModel))
  }

  var body: some Scene {
    WindowGroup {
      ContentView(viewModel: self.model.viewModel)
        .environmentObject(eventHandler)
        .environmentObject(model)
        .onAppear {
          LocalNotificationManager.sharedNotificationManager.requestAuthorization()
          Task {
            try await self.model.startSync()
            LocalNotificationManager.sharedNotificationManager.schedule(
              viewModel: self.model.viewModel)
          }
        }.onChange(of: scenePhase) { phase in
          Task {
            try await self.model.startSync()
            LocalNotificationManager.sharedNotificationManager.schedule(
              viewModel: self.model.viewModel)
          }
        }
    }
  }
}

// MARK: MedsMinderAppDelegate

// Added this here so that we can trigger a refresh when we get a notification.
final class MedsMinderAppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    application.registerForRemoteNotifications()
    UNUserNotificationCenter.current().delegate = self
    return true
  }

  func application(
    _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    debugPrint("Did register for remote notifications")
  }

  func application(
    _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    debugPrint("ERROR: Failed to register for notifications: \(error.localizedDescription)")
  }

  func application(
    _ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    guard
      let zoneNotification = CKNotification(fromRemoteNotificationDictionary: userInfo)
        as? CKRecordZoneNotification
    else {
      completionHandler(.noData)
      return
    }

    debugPrint("Received zone notification: \(zoneNotification)")

    Task {
      do {
        try await MedsMinderApp.sharedModel.startSync()
        completionHandler(.newData)
      } catch {
        debugPrint("Error in fetchLatestChanges: \(error)")
        completionHandler(.failed)
      }
    }
  }
}

// Conform to UNUserNotificationCenterDelegate
extension MedsMinderAppDelegate: UNUserNotificationCenterDelegate {

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Allow presentation of alerts while the app is running.
    completionHandler([.banner, .sound])
  }

}

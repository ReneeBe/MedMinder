//
//  RemindersView.swift
//  MedsMinder
//
//  Created by Renee Berger on 10/25/21.
//

import CloudKit
import SwiftUI
import UserNotifications
import os.log

struct RemindersView: View {
  @EnvironmentObject var eventHandler: EventHandler
  var viewModel: ViewModel
  var notificationsBuilder = LocalNotificationManager()
  @Environment(\.scenePhase) private var scenePhase
  @State private var showAddReminderView = false

  // This is used to update the sort when the time changes. Updating every second was too much.
  @State var currentDate = Date()
  let timer = Timer.publish(every: 20, on: .main, in: .common).autoconnect()

  var body: some View {
    NavigationView {
      ZStack {
        if viewModel.reminders.count == 0 {
          Text(
            "No reminders\n You can add reminders by tapping a medication in the \"Medications\" tab"
          ).multilineTextAlignment(.center)
            .padding().padding().font(.title).foregroundColor(.secondary)
        } else {
          List {
            // TODO: Reduce duplication here
            if remindersForLateSection.count > 0 {
              Section(header: Text("Late")) {
                ForEach(remindersForLateSection, id: \.0.id) { (reminder, medication) in
                  ReminderRowView(
                    showAddReminderView: showAddReminderView, rowViewState: .late,
                    reminder: reminder, viewModel: viewModel, medication: medication)
                }
                .onDelete(perform: { offsets in
                  let remindersToDelete = offsets.map { remindersForLateSection[$0].0 }
                  eventHandler.deleteReminders(reminders: remindersToDelete)
                })
              }
            }
            if remindersForNowSection.count > 0 {
              Section(header: Text("Now")) {
                ForEach(remindersForNowSection, id: \.0.id) { (reminder, medication) in
                  ReminderRowView(
                    showAddReminderView: showAddReminderView, rowViewState: .now,
                    reminder: reminder, viewModel: viewModel, medication: medication)
                }
                .onDelete(perform: { offsets in
                  let remindersToDelete = offsets.map { remindersForNowSection[$0].0 }
                  eventHandler.deleteReminders(reminders: remindersToDelete)
                })
              }
            }
            if remindersForUpComingSection.count > 0 {
              Section(header: Text("Upcoming")) {
                ForEach(remindersForUpComingSection, id: \.0.id) { (reminder, medication) in
                  ReminderRowView(
                    showAddReminderView: showAddReminderView, rowViewState: .upcoming,
                    reminder: reminder, viewModel: viewModel, medication: medication)
                }
                .onDelete(perform: { offsets in
                  let remindersToDelete = offsets.map { remindersForUpComingSection[$0].0 }
                  eventHandler.deleteReminders(reminders: remindersToDelete)
                })
              }
            }
            if remindersForUpCompletedSection.count > 0 {
              Section(header: Text("Completed")) {
                ForEach(remindersForUpCompletedSection, id: \.0.id) { (reminder, medication) in
                  ReminderRowView(
                    showAddReminderView: showAddReminderView, rowViewState: .completed,
                    reminder: reminder, viewModel: viewModel, medication: medication
                  ).grayscale(1.0).opacity(0.5)
                }
                .onDelete(perform: { offsets in
                  let remindersToDelete = offsets.map { remindersForUpCompletedSection[$0].0 }
                  eventHandler.deleteReminders(reminders: remindersToDelete)
                })
              }
            }
          }
          .listRowBackground(Color(.systemBlue).opacity(0.06))
          .foregroundColor(.primary)
          .listStyle(InsetListStyle())
        }
      }
      .navigationBarTitle("Reminders", displayMode: .automatic)
      .onReceive(timer) { input in
        currentDate = input
      }
    }
  }
}

// MARK: Data Processing Additions

// TODO: It would be great if this didn't recompute everything every time. I tried to make it cache
//       the results but didn't have great luck. It woudl still be useful to do and could reduce jank.
extension RemindersView {
  // now, upcoming, complete, overdue

  var sortedReminders: [Reminder] {
    return viewModel.reminders.sorted { a, b in
      if a.intakeTime.normalize() == b.intakeTime.normalize() {
        let aName = viewModel.medication(for: a)?.name
        let bName = viewModel.medication(for: b)?.name
        if aName != nil && bName != nil && aName != bName {
          return aName! < bName!
        }

        return a.medicationID.uuidString < b.medicationID.uuidString
      }
      return a.intakeTime.normalize() < b.intakeTime.normalize()
    }
  }

  func minutesFromNow(minutes: Int) -> Date {
    Calendar.current.date(byAdding: .minute, value: minutes, to: currentDate)!
  }

  func hasReminderBeenFullfilled(reminder: Reminder, medication: Medication) -> Bool {
    let todaysHistory = viewModel.history.filter({
      Calendar.current.isDateInToday($0.date) && $0.medicationID == medication.id
        && reminder.id == $0.reminderID
    })

    return todaysHistory.count > 0
  }

  func remindersSatisfyingPredicate(predicate: ((Reminder, Medication) -> Bool)) -> [(
    Reminder, Medication
  )] {
    return sortedReminders.reduce(
      [],
      { partialResult, reminder in
        if let medication: Medication = viewModel.medication(for: reminder) {
          if predicate(reminder, medication) {
            return partialResult + [(reminder, medication)]
          }
        }
        return partialResult
      })
  }

  // MARK: Late

  func shouldReminderBeInLateSection(reminder: Reminder, medication: Medication) -> Bool {
    return reminder.intakeTime.normalize() <= minutesFromNow(minutes: -5)
      && !hasReminderBeenFullfilled(reminder: reminder, medication: medication)
  }

  var remindersForLateSection: [(Reminder, Medication)] {
    return remindersSatisfyingPredicate(predicate: shouldReminderBeInLateSection)
  }

  // MARK: Now

  func shouldReminderBeInNowSection(reminder: Reminder, medication: Medication) -> Bool {
    return reminder.intakeTime.normalize() < minutesFromNow(minutes: 3)
      && reminder.intakeTime.normalize() > minutesFromNow(minutes: -5)
      && !hasReminderBeenFullfilled(reminder: reminder, medication: medication)
  }

  var remindersForNowSection: [(Reminder, Medication)] {
    return remindersSatisfyingPredicate(predicate: shouldReminderBeInNowSection)
  }

  // MARK: Upcoming

  func shouldReminderBeInUpComingSection(reminder: Reminder, medication: Medication) -> Bool {
    return reminder.intakeTime.normalize() > minutesFromNow(minutes: 3)
      && !hasReminderBeenFullfilled(reminder: reminder, medication: medication)
  }

  var remindersForUpComingSection: [(Reminder, Medication)] {
    return remindersSatisfyingPredicate(predicate: shouldReminderBeInUpComingSection)
  }

  // MARK: Completed

  func shouldReminderBeInCompletedSection(reminder: Reminder, medication: Medication) -> Bool {
    return hasReminderBeenFullfilled(reminder: reminder, medication: medication)
  }

  var remindersForUpCompletedSection: [(Reminder, Medication)] {
    return remindersSatisfyingPredicate(predicate: shouldReminderBeInCompletedSection)
  }
}

// MARK: Previews

struct RemindersView_Previews: PreviewProvider {
  static var previews: some View {
    let model = PreviewModel()
    Group {
      RemindersView(viewModel: ViewModel.data)
        .environmentObject(EventHandler(model: model)).environmentObject(model)
      RemindersView(viewModel: ViewModel())
        .environmentObject(EventHandler(model: model)).environmentObject(model)
    }
  }
}

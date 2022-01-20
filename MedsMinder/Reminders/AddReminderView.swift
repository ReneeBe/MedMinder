//
//  AddReminderView.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/2/21.

import Foundation
import SwiftUI

struct AddReminderView: View {
  @Binding var showAddReminderView: Bool
  @State var medication: Medication
  // TODO: Store all this in a data object instead?
  @State var title: String
  @State var reminders: [Reminder]
  @State var dosage: Double
  @State var delay: Int = 0
  @State var allowSnooze: Bool = true
  @State var notes: String = ""
  @State var indices: [Int] = []
  @State var historyToDelete: [History] = []
  @EnvironmentObject var eventHandler: EventHandler
  var viewModel: ViewModel
  static var enableAdditionalOptions = false

  var sortedHistory: [History] {
    return viewModel.history.filter({ $0.medicationID == medication.id }).sorted { a, b in
      a.date > b.date
    }
  }

  var filteredSortedHistory: [History] {
    return sortedHistory.filter { history in
      !historyToDelete.contains(where: { $0.id == history.id })
    }
  }

  // TODO: This is too long and needs to move
  var body: some View {
    NavigationView {
      ZStack {
        Rectangle()
          .fill(Color(.systemGray5).opacity(0.06)).ignoresSafeArea()
        VStack {
          MedImage(med: medication)
            .frame(width: 75, height: 75)
            .padding()
          Text(medication.name)
          List {
            Section {
              ForEach($reminders) { reminder in
                HStack {
                  Text("Intake")
                  Spacer()
                  DatePicker(
                    "", selection: reminder.intakeTime,
                    displayedComponents: .hourAndMinute)
                  Button(action: {
                    reminders.removeAll(where: { $0.id == reminder.id })
                  }) {
                    Image(systemName: "minus.circle.fill").foregroundColor(
                      Color(.systemRed)
                    )
                    .accessibility(label: Text("delete intake"))
                  }
                }
              }
              HStack {
                Button(action: {
                  reminders.append(
                    Reminder(
                      medicationID: medication.id, intakeTime: Date(),
                      intakeAmount: Double(dosage), delay: Int(delay),
                      allowSnooze: allowSnooze,
                      notes: notes))
                }) {
                  HStack {
                    Image(systemName: "plus.circle.fill").foregroundColor(
                      Color(.systemGreen))
                    Text("Add Intake")
                  }
                }
              }
            }
            Section(header: Text("History")) {
              if filteredSortedHistory.count > 0 {
                ForEach(filteredSortedHistory) { history in
                  Text(history.date.formatted())
                }.onDelete(perform: { offsets in
                  historyToDelete.append(contentsOf: offsets.map { filteredSortedHistory[$0] })
                })
              } else {
                Text("No history for this medication.")
              }
            }
            .listRowBackground(Color(.systemGray5))
            if AddReminderView.enableAdditionalOptions {
              Section {
                HStack {
                  Text("Amount Per Intake")
                  Picker("", selection: $dosage) {
                    Text("1/2 Tablet").tag(0.5)
                    Text("1 Tablet").tag(1.0)
                    Text("2 Tablets").tag(2.0)
                  }.accessibility(label: Text("Dosage Per Intake"))
                    .pickerStyle(MenuPickerStyle())
                }
                HStack {
                  Toggle(isOn: $allowSnooze) {
                    Text("Allow Snooze")
                  }.accessibility(label: Text("allow snooze"))
                }
                HStack {
                  Text("Max Delay")
                  Spacer()
                  Picker("Until next Intake", selection: $delay) {
                    Text("0 mins").tag(0)
                    Text("5 mins").tag(5)
                    Text("15 mins").tag(15)
                    Text("30 mins").tag(30)
                    Text("1 hr").tag(60)
                    Text("1.5 hrs").tag(90)
                    Text("2 hrs").tag(120)
                  }.accessibility(label: Text("Allowed Intake Delay"))
                }
                Menu("Priority") {
                  Text("Low")
                  Text("Medium")
                  Text("High")
                }
                HStack {
                  Text("Notes:")
                  Spacer()
                  TextEditor(text: $notes)
                }
                if medication.history.count > 0 {
                  HStack {
                    Text("History:")
                    Spacer()
                    Text(verbatim: String(medication.history[0].dosage))
                  }
                }
              }
              .listRowBackground(Color(.systemGray5))
            }
          }
          .listStyle(InsetGroupedListStyle())
        }
        .foregroundColor(.primary)
//        //MARK: PULL-TO-REFRESH DISABLED HERE
//        .refreshable{
//          if showAddReminderView == true {
//            print("we're trying this thing")
//          }
//        }
//        .disabled(true)
        .navigationBarTitle(Text(title), displayMode: .inline)
        .navigationBarItems(
          leading:
            Button(
              "Dismiss",
              action: {
                showAddReminderView = false
              }),
          trailing:
            Button(
              action: {
                eventHandler.replaceReminders(
                  medication: medication, reminders: reminders)
                eventHandler.deleteHistory(history: historyToDelete)
                showAddReminderView = false
              }, label: { Text("Save") })
        )
      }
    }
  }

  func hideTimes(index: Int) {
    indices.append(index)
  }
}

struct AddReminderView_Previews: PreviewProvider {
  static var pill: Medication = Medication.data[3]
  static var previousReminders: [Date] = [Date()]

  static var previews: some View {
    AddReminderView(
      showAddReminderView: .constant(true), medication: pill,
      title: "Medication Details",
      reminders: Reminder.data, dosage: 1.0, indices: [],
      viewModel: ViewModel.data)
  }
}

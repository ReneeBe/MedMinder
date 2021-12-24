//
//  ReminderRowView.swift
//  MedsMinder
//
//  Created by Renee Berger on 10/25/21.
//

import SwiftUI

enum RowViewState {
  case late
  case now
  case upcoming
  case completed
}

struct ReminderRowView: View {
  @State var showAddReminderView: Bool
  @State var rowViewState: RowViewState
  var reminder: Reminder
  var viewModel: ViewModel
  @EnvironmentObject var eventHandler: EventHandler
  var progress: Double = 270
  @State var medication: Medication

  var body: some View {
    HStack {
      if medication.dosage == 0.5 {
        MedImage(med: medication)
          .frame(width: 60, height: 60)
          .mask(Rectangle().padding(.top, 28))
          .shadow(radius: 2)
          .shadow(radius: 1)
          .padding(.trailing)
      } else {
        MedImage(med: medication)
          .frame(width: 60, height: 60)
          .padding(.trailing)
      }
      Button(action: {
        self.showAddReminderView = true
      }) {
        VStack(alignment: .leading) {
          Text(medication.name)
            .font(.title2).fontWeight(.semibold).foregroundColor(.primary)
          Text(dateFormatting(date: reminder.intakeTime))
            .font(.callout).foregroundColor(.secondary)
        }
      }
      .buttonStyle(PlainButtonStyle())
      .sheet(
        isPresented: $showAddReminderView, onDismiss: didDismissAddReminders,
        content: {
          let dosage = medication.dosage
          AddReminderView(
            showAddReminderView: $showAddReminderView, medication: medication,
            title: "Medication Details",
            reminders: viewModel.reminders(for: medication), dosage: dosage, indices: [],
            viewModel: viewModel)
        })
      Spacer()
      Button(
        action: {
          eventHandler.reminderRowButtonPressed(
            reminder: reminder, medication: medication, rowViewState: rowViewState)
        },
        label: {
          Text(rowViewState == .completed ? "Undo" : "Take")
            .padding(7)
            .font(Font.body.weight(.bold))
            .foregroundColor(Color(.systemBlue))
            .background(
              RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color(.systemGray5))
            )
        }
      )
      .buttonStyle(BorderlessButtonStyle())
    }
    .padding()
  }

  func didDismissAddReminders() {
  }

  // TODO: This looks shared, make it so
  func dateFormatting(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .short
    return dateFormatter.string(from: date)
  }

}

struct ReminderRowView_Previews: PreviewProvider {
  static var medOne: Medication = Medication.data[1]
  static var medTwo: Medication = Medication.data[2]

  static var previews: some View {
    VStack {
      RowView(
        showAddReminderView: false, medication: medOne,
        viewModel: ViewModel.data, progress: 270)
      RowView(
        showAddReminderView: false,
        medication: medTwo,
        viewModel: ViewModel.data)
    }.environmentObject(EventHandler(model: PreviewModel()))
  }
}

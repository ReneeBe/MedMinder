//
//  RowView.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/1/21.
//

import SwiftUI

struct RowView: View {
  @EnvironmentObject var eventHandler: EventHandler
  @State var showAddReminderView: Bool
  var medication: Medication
  var viewModel: ViewModel

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
          Text(subtitleText()).font(.subheadline)
            .foregroundColor(.secondary)
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
          eventHandler.medicationRowButtonPressed(
            medication: medication, reminder: getNextReminder())
        },
        label: {
          Text("Take")
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
      .disabled(shouldDisableButton)
      .grayscale(shouldDisableButton ? 0.8 : 0)
      .opacity(shouldDisableButton ? 0.5 : 1.0)
    }
    .padding()
  }

  var shouldDisableButton: Bool {
    return !viewModel.reminders(for: medication).isEmpty && getNextReminder() == nil
  }

  func didDismissAddReminders() {
  }

  func dateFormatting(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .short
    return dateFormatter.string(from: date)
  }

  func getNextReminder() -> Reminder? {
    let reminders = viewModel.reminders.filter({
      $0.medicationID == medication.id
        && !viewModel.hasReminderBeenFullfilled(reminder: $0)
    })
    .sorted()

    return reminders.first
  }

  func getNextReminderTime() -> String? {
    let reminders = viewModel.reminders.filter({
      $0.medicationID == medication.id
        && !viewModel.hasReminderBeenFullfilled(reminder: $0)
    })
    .sorted()
    return reminders.map { dateFormatting(date: $0.intakeTime) }.first
  }

  func subtitleText() -> String {
    let nextReminderTime = getNextReminderTime()
    let count = viewModel.reminders(for: medication).count
    var text = ""
    if nextReminderTime != nil {
      text = "Next Reminder: \(nextReminderTime!)"
    } else if count > 0 {
      text = "Done for Today"
    } else if count == 0 {
      text = "\(viewModel.todaysHistoryCountFor(medication:medication)) Taken Today"
    }
    return text
  }
}

// MARK: Previews

struct RowView_Previews: PreviewProvider {
  static var medOne: Medication = Medication.data[1]
  static var medTwo: Medication = Medication.data[2]

  static var previews: some View {
    Group {
      RowView(
        showAddReminderView: false,
        medication: medOne,
        viewModel: ViewModel.data)

      RowView(
        showAddReminderView: false,
        medication: medTwo,
        viewModel: ViewModel.data)

      RowView(
        showAddReminderView: false,
        medication: Medication.data[3],
        viewModel: ViewModel.data
      )
      .preferredColorScheme(.dark)
    }
    .environmentObject(EventHandler(model: PreviewModel()))
    .previewLayout(.sizeThatFits)
  }
}

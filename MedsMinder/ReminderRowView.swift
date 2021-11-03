//
//  ReminderRowView.swift
//  MedsMinder
//
//  Created by Renee Berger on 10/25/21.
//

import SwiftUI

struct ReminderRowView: View {
    @State var showAddReminderView: Bool
    @Binding var permissionGranted: Bool
    @Binding var reminder: Reminder
    @EnvironmentObject var data: ViewModel
    var progress: Double = 270
    var med: Med
    
    var body: some View {
        HStack {
            if med.dosage == 0.5 {
                MedImage(med: med)
                    .padding()
                    .mask(Rectangle().padding(.top, 35))
            } else {
                MedImage(med: med)
                    .padding()
            }
            Button(action: {
                self.showAddReminderView = true
                print("permissionGranted?: \(permissionGranted)")
            }) {
                    VStack(alignment: .leading) {
                        Text(reminder.medName)
                            .font(.title2).fontWeight(.semibold)
                        Text(dateFormatting( date: reminder.intakeTime))
                            .font(.callout)
                    }
                    .foregroundColor(Color(.darkGray))
            }
            .buttonStyle(PlainButtonStyle())
//            .sheet(isPresented: $showAddReminderView, content: {
//                let times = med.reminders != [] ? med.reminders[0].intakeTimes : []
//                let intakeType = med.reminders != [] ? med.reminders[0].intakeType : "Scheduled Intake"
//                let dosage = med.dosage
//                AddReminderView(showAddReminderView: $showAddReminderView, med: $med, intakeType: intakeType, times: times, dosage: dosage, indices: [], permissionGranted: $permissionGranted)
//            })
            Spacer()
            Button(action: {
                print("\(reminder.medName) taken!")
                let newHistory = History(date: Date(), dosage: reminder.intakeAmount)
                if var currentMed = data.medData.first(where: {$0.name == reminder.medName}) {
                    currentMed.history.append(newHistory)
                    print(currentMed.history)
                }
//                currentMed.history.append(newHistory)
//                print(currentMed.history)
            }, label: {
//                if med[0].scheduled! {
                    Text("TAKE")
                        .padding(7)
                        .font(Font.body.weight(.bold))
                        .foregroundColor(Color(.systemBlue))
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(Color(.systemGray5))
                        )
//                } else {
//                    ProgressBar(progress: progress)
//                        .padding(.horizontal, -20)
//                }
            })
            .buttonStyle(BorderlessButtonStyle())

        }
        .padding()
//        Divider()
//    }
    }
    
    func dateFormatting(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}

struct ReminderRowView_Previews: PreviewProvider {
    static var medOne: Med = Med.data[1]
    static var medTwo: Med = Med.data[2]
    
    static var previews: some View {
        VStack {
            RowView(showAddReminderView: false, permissionGranted: .constant(true), med: .constant(medOne), progress: 270)
            RowView(showAddReminderView: false, permissionGranted: .constant(true), med: .constant(medTwo), progress: 270)
        }
    }
}

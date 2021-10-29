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
    
    var body: some View {
        var med = data.medData.filter {$0.name == reminder.medName}

        HStack {
            if med[0].dosage == 0.5 {
                MedImage(med: med[0])
                    .padding()
                    .mask(Rectangle().padding(.top, 35))
            } else {
                MedImage(med: med[0])
                    .padding()
            }
            Button(action: {
                self.showAddReminderView = true
                print("permissionGranted?: \(permissionGranted)")
            }) {
                    VStack(alignment: .leading) {
                        Text(med[0].name)
                            .font(.title2).fontWeight(.semibold)
                        Text(med[0].details)
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
                print("\(med[0].name) taken!")
                let newHistory = History(date: Date(), dosage: med[0].dosage)
                med[0].history.append(newHistory)
            }, label: {
                if med[0].scheduled! {
                    Text("TAKE")
                        .padding(7)
                        .font(Font.body.weight(.bold))
                        .foregroundColor(Color(.systemBlue))
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(Color(.systemGray5))
                        )
                } else {
                    ProgressBar(progress: progress)
                        .padding(.horizontal, -20)
                }
            })
            .buttonStyle(BorderlessButtonStyle())

        }
        .padding()
//        Divider()
//    }
    }
}

struct ReminderRowView_Previews: PreviewProvider {
    static var medOne: Med = Med.data[1]
    static var medTwo: Med = Med.data[2]
    
    static var previews: some View {
        VStack {
            RowView(showAddReminderView: false, permissionGranted: .constant(true), med: .constant(medOne), progress: 270)
            RowView(showAddReminderView: false, permissionGranted: .constant(true), med: .constant(medTwo), progress: 270)
        }    }
}

//
//  RowView.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/1/21.
//

import SwiftUI

struct RowView: View {
    @State var showAddReminderView: Bool
    @Binding var permissionGranted: Bool
    @Binding var med: Med
    var progress: Double = 270
    
    
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
                        Text(med.name)
                            .font(.title2).fontWeight(.semibold)
                        Text(med.details)
                            .font(.callout)
                    }
                    .foregroundColor(Color(.darkGray))
            }
            .sheet(isPresented: $showAddReminderView, content: {
                let times = med.reminders != [] ? med.reminders[0].intakeTimes : []
                let intakeType = med.reminders != [] ? med.reminders[0].intakeType : "Scheduled Intake"
                let dosage = med.dosage
                AddReminderView(showAddReminderView: $showAddReminderView, med: $med, intakeType: intakeType, times: times, dosage: dosage, indices: [], permissionGranted: $permissionGranted)
            })
            Spacer()
            Button(action: {
                print("\(med.name) taken!")
                let newHistory = History(date: Date(), dosage: med.dosage)
                med.history.append(newHistory)
            }, label: {
                if med.scheduled! {
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
        }
        .padding()
        Divider()
    }
}

struct RowView_Previews: PreviewProvider {
    static var medOne: Med = Med.data[1]
    static var medTwo: Med = Med.data[2]

    static var previews: some View {
        VStack {
            RowView(showAddReminderView: false, permissionGranted: .constant(true), med: .constant(medOne))
            RowView(showAddReminderView: false, permissionGranted: .constant(true), med: .constant(medTwo))
        }
    }
}

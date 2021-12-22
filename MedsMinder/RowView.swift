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
    @EnvironmentObject var data: ViewModel
    var progress: Double = 270
    var timeRows: [GridItem] = Array(repeating: .init(.adaptive(minimum: 80)), count: 3)
    
    var body: some View {
        HStack {
            if med.dosage == 0.5 {
                MedImage(med: med)
                    .frame(width: 60, height: 60)
                    .mask(Rectangle().padding(.top, 28))
                    .shadow(radius: 2)
                    .shadow(radius: 1)
                    .padding(.trailing)
            } else {
                MedImage(med: med)
                    .frame(width: 60, height: 60)
                    .padding(.trailing)
            }
            Button(action: {
                self.showAddReminderView = true
//                print("medName and medColor: \(String(describing: med.name)), \(String(describing: med.color))")
//                print(med.color)

                print("permissionGranted?: \(permissionGranted)")
            }) {
                    VStack(alignment: .leading) {
                        Text(med.name)
                            .font(.title2).fontWeight(.semibold)
                        let times = getTimes()
                        LazyHGrid(rows: timeRows, alignment: .top) {
                            ForEach(0..<times.count, id: \.self) { i in
                                Text(times[i])
                                    .font(.caption2)
                            }
                        }
                    }
                    .foregroundColor(Color(.darkGray))
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showAddReminderView, onDismiss: didDismissAddReminders, content: {
                let times: [Date] = collectReminderTimes()
                let intakeType = med.reminders != [] ? "Scheduled Intake" : "On Demand"
                let dosage = med.dosage
                AddReminderView(showAddReminderView: $showAddReminderView, med: $med, title: "Medication Details", intakeType: intakeType, times: times, dosage: dosage, indices: [], permissionGranted: $permissionGranted)
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
                        .padding(.horizontal, -10)
                }
            })
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding()
    }
    
    func didDismissAddReminders() {
        print("we dismissed add reminderview")
        data.getMedData() { _ in }
        data.getReminderData(){ _ in }
    }
    
    func dateFormatting(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
    func getTimes() -> [String] {
        let reminders = data.reminderData.filter {$0.medName == med.name}
        return reminders.map { dateFormatting(date: $0.intakeTime)}
    }
    
    func collectReminderTimes() -> [Date] {
        var intakeTimes: [Date] = []
        let reminders = data.reminderData.filter{$0.medName == med.name}
        if reminders != [] {
            for reminder in reminders {
                intakeTimes.append(reminder.intakeTime)
            }
        }
        if intakeTimes == [] {
            intakeTimes = [Date()]
        }
        return intakeTimes
    }
    
}

struct RowView_Previews: PreviewProvider {
    static var medOne: Med = Med.data[1]
    static var medTwo: Med = Med.data[2]

    static var previews: some View {
        VStack {
            RowView(showAddReminderView: false, permissionGranted: .constant(true), med: .constant(medOne), progress: 270)
            RowView(showAddReminderView: false, permissionGranted: .constant(true), med: .constant(medTwo), progress: 270)
        }
    }
}

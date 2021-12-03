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
    @State var med: Med
    
    var body: some View {
        HStack {
            if med.dosage == 0.5 {
                MedImage(med: med)
                    .frame(width: 60, height: 60)
                    .padding(.trailing)
                    .mask(Rectangle().padding(.top, 30))

//                    .padding()
//                    .mask(Rectangle().padding(.top, 45))
                    .shadow(radius: 2)
                    .shadow(radius: 1)
            } else {
                MedImage(med: med)
                    .frame(width: 60, height: 60)
                    .padding(.trailing)
            }
//            Spacer()
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
            .sheet(isPresented: $showAddReminderView,onDismiss: didDismissAddReminders, content: {
                let times: [Date] = collectReminderTimes()
                let intakeType = med.reminders != [] ? "Scheduled Intake" : "On Demand"

//                let intakeType = med.reminders != [] ? med.reminders[0].intakeType : "Scheduled Intake"
                let dosage = med.dosage
                AddReminderView(showAddReminderView: $showAddReminderView, med: $med, title: "Medication Details", intakeType: intakeType, times: times, dosage: dosage, indices: [], permissionGranted: $permissionGranted)
            })
            Spacer()
            Button(action: {
                print("\(reminder.medName) taken!")
                let newHistory = History(date: Date(), dosage: reminder.intakeAmount)
                if var currentMed = data.medData.first(where: {$0.name == reminder.medName}) {
                    currentMed.history.append(newHistory)
                    print(currentMed.history)
//                    data.saveHistoryRecord(history: newHistory) { _ in }
                    data.findMedForRecID(med: currentMed, reminders: nil, history: newHistory, process: "createHistory") { _ in }
                }
                
//                data.findMedForRecID(med: currentMed, reminders: <#T##[Reminder]?#>, process: <#T##String#>, completionHandler: <#T##(Result<Void, Error>) -> Void#>)
                
                
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

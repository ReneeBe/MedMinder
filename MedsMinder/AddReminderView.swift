//
//  AddReminderView.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/2/21.
//

import SwiftUI
import Foundation


struct TimeRowView: View {
    @Binding var selectedTime: Date
    func formatter() -> String {
        let dateMaker = DateFormatter()
        dateMaker.timeStyle = .short
        let dateString = dateMaker.string(from: Date())
        return dateString
    }

    var body: some View {
        HStack {
            Text("Intake")
            Spacer()
            DatePicker("", selection: self.$selectedTime, displayedComponents:.hourAndMinute)
        }
    }
}

struct AddReminderView: View {
    @Binding var showAddReminderView: Bool
    @Binding var med: Med
    @State var intakeType: String
    @State var times: [Date]
    @State var dosage: Double
    @State var delay: Int = 0
    @State var allowSnooze: Bool = true
    @State var notes: String = ""
    
    func formatter(date: Date) -> String {
        let dateMaker = DateFormatter()
        dateMaker.timeStyle = .short
        let dateString = dateMaker.string(from: date)
        return dateString
    }

    enum intakeTypes: String, CaseIterable, Identifiable {
        case scheduled = "Scheduled Intake"
        case demand = "On Demand"

        var id: String { self.rawValue }
    }

    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .fill(Color(.systemGray5).opacity(0.06)).ignoresSafeArea()
                VStack {
                    MedImage(med: med)
                        .padding()
                    Text(med.name)
                    Picker("Dosage Category", selection: $intakeType) {
                        ForEach(intakeTypes.allCases) { intake in
                            Text("\(intake.rawValue)").tag(intake)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    List {
                        Section {
                            ForEach(0..<times.count, id: \.self) { i in
                                TimeRowView(selectedTime: self.$times[i])
                            }
                            HStack {
                                Button(action: {
                                    print("add intake")
                                    times.append(Foundation.Date())
                                    print(times)
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill").foregroundColor(Color(.systemGreen))
                                        Text("Add Intake")
                                    }
                                }
                            }
                        }
                        .listRowBackground(Color(.systemGray5))
                        Section {
                            HStack {
                                Text("Amount Per Intake")
                                Picker("", selection: $dosage) {
                                    Text("1/2 Tablet").tag(0.5)
                                    Text("1 Tablet").tag(1.0)
                                    Text("2 Tablets").tag(2.0)
                                }.accessibility(label: Text("Dosage Per Intake"))
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
                        }.listRowBackground(Color(.systemGray5))
                    }.listStyle(InsetGroupedListStyle())
            }
            .foregroundColor(Color(.darkGray))
            .navigationBarTitle(Text("Add Reminder"), displayMode: .inline)
            .navigationBarItems(
                leading:
                    Button(action: { showAddReminderView = false }, label: {Text("Cancel")}
                    ),
                trailing:
                    Button(action: {
                        print("save")
//                        times = times.sorted()
                        let newReminder = Reminder(medName: med.name, intakeType: intakeType, intakeTimes: times, intakeAmount: Double(dosage), delay: Int(delay), allowSnooze: allowSnooze, notes: notes)
                        med.reminders.insert(newReminder, at: 0)
                        med.dosage = Double(dosage)
//                        let updateToScheduled = intakeType == "Scheduled Intake" ? true : false
//                        med.showAsScheduled = updateToScheduled
                        showAddReminderView.toggle()
                    }) {
                        Text("Save")
                    }
                )
            }
        }
    }
}

struct AddReminderView_Previews: PreviewProvider {
    static var pill: Med = Med.data[1]
    static var previousReminders: [Date] = Med.data[1].reminders[0].intakeTimes != [] ? Med.data[1].reminders[0].intakeTimes : [Foundation.Date()]
    
    static var previews: some View {
        AddReminderView(showAddReminderView: .constant(true), med: .constant(pill), intakeType: "Scheduled Intake", times: previousReminders, dosage: 1.0)
    }
}

//            .background(Color(.systemGray3).opacity(0.04).ignoresSafeArea())

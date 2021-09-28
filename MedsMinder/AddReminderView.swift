//
//  AddReminderView.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/2/21.
//

import SwiftUI
import Foundation

struct AddReminderView: View {
    @Binding var showAddReminderView: Bool
    @Binding var med: Med
    @State var intakeType: String
    @State var times: [Date]
    @State var dosage: Double
    @State var delay: Int = 0
    @State var allowSnooze: Bool = true
    @State var notes: String = ""
    @State var indices: [Int] = []
    
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
                                if !indices.contains(i) {
                                    HStack {
                                        Text("Intake")
                                        Spacer()
                                        DatePicker("", selection: self.$times[i], displayedComponents:.hourAndMinute)
                                        Button(action:
                                                {
                                                    hideTimes(index: i)
                                                }
                                        ) {
                                            Image(systemName: "minus.circle.fill").foregroundColor(Color(.systemRed))
                                                .accessibility(label: Text("delete intake"))
                                        }
                                    }
                                }
                            }
                            HStack {
                                Button(action: {
                                    times.append(Foundation.Date())
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
                        indices.sort(by: >)
                        let tidiedTimes = delete()
                        let newReminder = Reminder(medName: med.name, intakeType: intakeType, intakeTimes: tidiedTimes ?? [Foundation.Date()], intakeAmount: Double(dosage), delay: Int(delay), allowSnooze: allowSnooze, notes: notes)
//                        let newReminder = Reminder(medName: med.name, intakeType: intakeType, intakeTimes: times, intakeAmount: Double(dosage), delay: Int(delay), allowSnooze: allowSnooze, notes: notes)
                        med.reminders.insert(newReminder, at: 0)
                        med.dosage = Double(dosage)
                        med.scheduled = intakeType == "Scheduled Intake" ? true : false
                        showAddReminderView = false
                        med.update(from: med.data)
                        print(med.reminders[0].intakeTimes)
                    }) {
                        Text("Save")
                    }
                )
            }
        }
    }
    func hideTimes(index: Int) {
        indices.append(index)
    }
    func delete() -> [Date]? {
        var copy: [Date]? = []
        for index in 0..<times.count {
            if !indices.contains(index) {
                copy?.append(times[index])
            }
        }
        copy!.sort()
        return copy
    }
}


struct AddReminderView_Previews: PreviewProvider {
    static var pill: Med = Med.data[1]
    static var previousReminders: [Date] = Med.data[1].reminders[0].intakeTimes != [] ? Med.data[1].reminders[0].intakeTimes : [Foundation.Date()]
    
    static var previews: some View {
        AddReminderView(showAddReminderView: .constant(true), med: .constant(pill), intakeType: "Scheduled Intake", times: previousReminders, dosage: 1.0, indices: [])
    }
}

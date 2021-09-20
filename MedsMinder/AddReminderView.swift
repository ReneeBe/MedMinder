//
//  AddReminderView.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/2/21.
//

import SwiftUI

struct TimeRowView: View {
    var body: some View {
        HStack {
            Text("First Intake")
            Spacer()
            DatePicker("", selection: /*@START_MENU_TOKEN@*/.constant(Date())/*@END_MENU_TOKEN@*/, displayedComponents:.hourAndMinute)
        }
    }
}

struct AddReminderView: View {
    @Binding var showAddReminderView: Bool
    var med: Med
    @State var selectedDosageDetails: String = "Scheduled Intake"
    @State var dosage: Double = 0.5
    @State var delay: Int = 0
    @State var allowSnooze: Bool = true
    @State var notes: String = ""

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
                    Picker("Dosage Category", selection: $selectedDosageDetails) {
                        ForEach(intakeTypes.allCases) { intake in
                            Text("\(intake.rawValue)").tag(intake)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    List {
                        Section {
//                            ForEach(med.)
//
                            
                            HStack {
                                Text("First Intake")
                                Spacer()
                                DatePicker("", selection: /*@START_MENU_TOKEN@*/.constant(Date())/*@END_MENU_TOKEN@*/, displayedComponents:.hourAndMinute)
                            }
                            HStack {
                                Text("Second Intake")
                                DatePicker("", selection: /*@START_MENU_TOKEN@*/.constant(Date())/*@END_MENU_TOKEN@*/, displayedComponents:.hourAndMinute)
                            }
                            HStack {
                                Button(action: {print("add intake")}) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill").foregroundColor(Color(.systemGreen))
                                        Text("Add Intake")
                                    }
                                }
                            }
                        }.listRowBackground(Color(.systemGray5))
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
                                }.accessibility(label: Text("Dosage Per Intake"))
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
    
    static var previews: some View {
        AddReminderView(showAddReminderView: .constant(true), med: pill)
    }
}

//            .background(Color(.systemGray3).opacity(0.04).ignoresSafeArea())

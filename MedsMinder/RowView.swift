//
//  RowView.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/1/21.
//

import SwiftUI

struct RowView: View {
    @State var showAddReminderView: Bool
    @State var med: Med
    var keyword: String
    var progress: Double
    
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
                print("show popover!"); print(showAddReminderView); print(med)
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
                AddReminderView(showAddReminderView: $showAddReminderView, med: $med)
            })
            Spacer()
            Button(action: {print("\(med.name) taken!")}, label: {
                if keyword == "scheduled" {
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
            RowView(showAddReminderView: true, med: medOne, keyword: "scheduled", progress: 270)
            RowView(showAddReminderView: true, med: medTwo, keyword: "", progress: 270)
        }
    }
}

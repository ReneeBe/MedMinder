//
//  MedicationsView.swift
//  MedsMinder
//
//  Created by Renee Berger on 10/22/21.
//

import SwiftUI
import UserNotifications
import CloudKit

struct MedicationsView: View {
    @EnvironmentObject var data: ViewModel
    @Binding var permissionGranted: Bool
    @State private var showNewMedPopover = false
    @State private var showAddReminderView = false
    
    var body: some View {
        
//        NavigationView {
        
            ZStack {
                Color(.systemBlue).opacity(0.06).ignoresSafeArea()
                List{
                    HStack (alignment: .top) {
                        Image(systemName: "timer")
                        Text("Scheduled")
                        Spacer()
                    }
                    .font(.headline)
                    .padding(.leading)
                    .padding(.top)
    //                    Divider()
                    ForEach(0..<data.medData.count, id: \.self) { i in
                        if data.medData[i].scheduled! {
                            RowView(showAddReminderView: showAddReminderView, permissionGranted: $permissionGranted, med: self.$data.medData[i])
                        }
                    }
                    
                    HStack (alignment: .top){
                        Text("On Demand")
                        Spacer()
                    }
                    .font(.headline)
                    .padding(.leading)
                    .padding(.top)
    //                    Divider()
                    ForEach(0..<data.medData.count, id: \.self) { i in
                        if data.medData[i].scheduled! == false {
                            RowView(showAddReminderView: showAddReminderView, permissionGranted: $permissionGranted, med: self.$data.medData[i])
                        }
                    }
//                    .onDelete(perform: self.deleteMeds)
                }
                .listRowBackground(Color(.systemBlue).opacity(0.06))
                .foregroundColor(Color(.darkGray))
                .listStyle(InsetListStyle())
    //                .padding(15)
            }
//            .navigationBarTitle("Medications")
        }
        
//    }
}

struct MedicationsView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationsView(permissionGranted: .constant(false))
    }
}

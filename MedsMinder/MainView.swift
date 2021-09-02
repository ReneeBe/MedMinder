//
//  ContentView.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/1/21.
//

import SwiftUI

struct MainView: View {
    @Binding var meds: [Med]
    
    var body: some View {
        ZStack {
            Color(.systemBlue).opacity(0.05).ignoresSafeArea()
            VStack {
                Spacer()
                Spacer()
                HStack {
                    Text("Edit").font(.subheadline).padding()
                    Spacer()
                    Image(systemName: "plus").padding()
                }
                HStack {
                    Text("Reminder").font(.largeTitle)
                        .padding()
                    Spacer()
                }
                HStack (alignment: .top){
                    Image(systemName: "timer")
                    Text("Scheduled")
                    Spacer()
                }
                .padding(.leading)
                .font(.headline)
                
                List {
                    ForEach(meds) { med in
                        if med.frequencyInMinutes > 0 {
                            RowView(med: med, keyword: "scheduled")
                        }
                    }
                }
              
                HStack (alignment: .top){
                    Text("On Demand")
                    Spacer()
                }
                .padding(.leading)
                .font(.headline)
                List {
                    ForEach(meds) { med in
                        if med.frequencyInMinutes == 0 {
                            RowView(med: med, keyword: "demand")
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(meds: .constant(Med.data))
    }
}

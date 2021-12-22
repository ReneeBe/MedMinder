//
//  MainNavigationBar.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/9/21.
//

import SwiftUI

struct MainNavigationBar: View {
    var body: some View {
        NavigationView {
            Text("")
                .navigationBarTitle("Reminder")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading:
                        EditButton(),
                    trailing:
                        Button(action: {print("Add Medication Sheet Open")}) {
                            Image(systemName: "plus")
                        }.accessibility(label: Text("Add New Medication"))
                )
        }
    }
}

struct MainNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        MainNavigationBar()
    }
}

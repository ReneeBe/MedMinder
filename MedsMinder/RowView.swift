//
//  RowView.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/1/21.
//

import SwiftUI

struct RowView: View {
    var med: Med
    var keyword: String
    
    var body: some View {
        HStack {
            Image(systemName: "capsule")
            VStack {
                Text(med.name)
                    .font(.headline)
                Text(med.details)
                    .font(.subheadline)
            }
            Spacer()
            Button(action: {}, label: {
                if keyword == "scheduled" {
                    Text("TAKE")
                        .padding(5)
                        .font(Font.caption.weight(.bold))
                        .foregroundColor(Color(.systemBlue))
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(Color(.systemGray5))
                        )
                } else {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 3)
                        .background(Circle().fill(Color(.systemBlue)))
                        .padding(5)
                        .frame(width: 39, height: 39, alignment: .trailing)
                }
            })
        }
        .frame(width: 350, height: 39)
    }
}

struct RowView_Previews: PreviewProvider {
    static var med: Med = Med.data[0]

    static var previews: some View {
        VStack {
        RowView(med: med, keyword: "")
        RowView(med: med, keyword: "")
        }
    }
}

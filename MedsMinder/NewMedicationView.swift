//
//  NewMedicationView.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/2/21.
//

import SwiftUI

struct NewMedicationView: View {
     @Binding var medData: Med.Data
     enum MedType:String, CaseIterable, Identifiable {
        case tablet
        case capsule
        case liquid
        var id: MedType { self }
    }
     var medShapes: [ [String] ] = [
    ["circle", "3"], ["circle", "2"], ["circle","1"], ["capsule", "3"], ["capsule","1"], ["oval", "2"], ["oval", "3"], ["rhombus", "3"]
    ]
     
    public var fourColumnGrid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack {
          Rectangle().fill(Color(.systemGray5).opacity(0.06)).ignoresSafeArea()
          VStack {
               Group {
                    TextField("Input Medication Name", text: $medData.name)
                         .padding(.horizontal)
                         .padding(.top, 25)
                    Image(systemName: "pills")
                         .font(.largeTitle)
                         .imageScale(.large)
                         .foregroundColor(medData.color != nil ? medData.color : Color(.systemGray2))
                         .overlay(
                              ZStack {
                                   Text(medData.engraving).bold()
                                        .shadow(color: Color.white, radius: 3)
                                        .shadow(color: Color.white, radius: 3)
                              }
                              .frame(width: 200, height: 75)
                         )
                    Picker("Medication Format", selection: $medData.format) {
                         ForEach(MedType.allCases) { med in
                              Text(med.rawValue)
                         }
                    }
                   .pickerStyle(SegmentedPickerStyle())
                   .padding()
               }
               Divider()
               HStack {
                   Spacer()
//                    ColorPicker("Pill color", selection: $medData.color)
//                       .padding(.horizontal)
               }
               Divider()
               Group {
                   HStack {
                       Text("Shape")
                           .fontWeight(.bold)
                           .padding()
                       Spacer()
                   }
                   LazyVGrid(columns: fourColumnGrid, alignment: .center, spacing: 10) {
                       ForEach(medShapes, id: \.self) {
                         let shape = $0[0]
                         let size = $0[1]
//                         let description = size == "3" ? "large" : size == "1" ? "small" : "medium"
                         let selected: Bool = medData.shape == [shape, size]
                         Button(action: {
                              medData.shape = [shape, size]
                         }) {
                              ZStack {
                                   Image(systemName: "\(medData.shape[0])")
                                       .foregroundColor(.white)
                                       .font(.title)
                                       .imageScale(size == "3" ? .large : size == "1" ? .small : .medium)
                                        .accessibility(label: Text("a /(medData.description) /(medData.shape)"))
                                   Image(systemName: "\(medData.shape[0])")
                                        .foregroundColor(.gray)
                                        .font(.largeTitle)
                                        .imageScale(size == "3" ? .large : size == "1" ? .small : .medium)
                                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 0)
                                        .padding(12)
                               }
                               .background(
                                   RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .strokeBorder(selected ? Color(.systemGray3) : Color.white, lineWidth: 3)
                               )
                           }
                       }
                   }
               }
               Divider()
               Group {
                    HStack {
                         Text("Engraving")
                              .fontWeight(.bold)
                              .padding()
                         Spacer()
                    }
                    TextField("ABC", text: $medData.engraving)
                         .foregroundColor(Color(.darkGray))
                         .font(.title)
                         .padding()
                         .padding(.horizontal, 100)
                         .overlay(
                              Capsule()
                                   .stroke(Color(.systemGray3), lineWidth: 3)
                                   .frame(width: 80, height: 45)
                         )
                         .padding(.horizontal, 50)
               }
          }
          .foregroundColor(Color(.darkGray))

        }
    }
}

struct NewMedicationView_Previews: PreviewProvider {
    static var previews: some View {
          NewMedicationView(medData: .constant(Med.data[0].data))
    }
}

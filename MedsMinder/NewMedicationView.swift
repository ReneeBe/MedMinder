//
//  NewMedicationView.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/2/21.
//

import SwiftUI

struct NewMedicationView: View {
     @Binding var medData: Med.Data
     @Binding var color: Color
     enum medType:String, CaseIterable, Identifiable {
          case tablet = "tablet"
          case capsule = "capsule"
          case liquid = "liquid"
          
          var id: String { self.rawValue }
    }
     var medShapes: [ [String] ] = [
    ["circle.fill", "3"], ["circle.fill", "2"], ["circle.fill","1"], ["capsule.fill", "3"], ["capsule.fill","1"], ["oval.fill", "2"], ["oval.fill", "3"], ["rhombus.fill", "3"]
    ]
     
    public var fourColumnGrid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack {
          Rectangle().fill(Color(.systemGray5).opacity(0.06)).ignoresSafeArea()
          VStack {
               Group {
                    TextField("Input Medication Name", text: $medData.name)
                         .padding(.horizontal)
                    Image(systemName: medData.shape[0] != "" ? medData.shape[0] : "pills")
                         .resizable()
                         .scaledToFit()
                         .foregroundColor(color)
                         .frame(width: 75, height: 75)
                         .overlay(
                              ZStack {
                                   Text(medData.engraving).bold()
                                        .shadow(color: Color.white, radius: 3)
                                        .shadow(color: Color.white, radius: 3)
                              }
                         )
                    Picker("Medication Format", selection: $medData.format) {
                         ForEach(medType.allCases) { med in
                              Text(med.rawValue)
                         }
                    }
                    .pickerStyle(SegmentedPickerStyle())
//                   .padding()
               }
               
               Divider()
               
               HStack {
                   Spacer()
                    ColorPicker("Pill color", selection: $color, supportsOpacity: false)
                       .padding(.horizontal)
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
//                         let sizeDescription = size == "3" ? "large" : size == "1" ? "small" : "medium"
                         let selected: Bool = medData.shape == [shape, size]
                         Button(action: {
                              medData.shape = [shape, size]
                         }) {
                              ZStack {
                                   Image(systemName: shape)
                                       .foregroundColor(.white)
                                       .font(.title)
                                       .imageScale(size == "3" ? .large : size == "1" ? .small : .medium)
                                   Image(systemName: "\(shape)")
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
//          .foregroundColor(Color(.darkGray))
        }
    }
}

struct NewMedicationView_Previews: PreviewProvider {
    static var previews: some View {
     NewMedicationView(medData: .constant(Med.data[0].data), color: .constant(Color(.systemGreen)))
    }
}

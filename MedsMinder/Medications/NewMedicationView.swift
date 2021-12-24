//
//  NewMedicationView.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/2/21.
//

import SwiftUI

struct NewMedicationView: View {
  @Binding var medData: Medication.Data
  @Binding var color: [Color]
  var medShapes: [[String]] = [
    ["circle.fill", "3"], ["circle.fill", "2"], ["circle.fill", "1"], ["capsule.fill", "3"],
    ["capsule.fill", "1"], ["oval.fill", "2"], ["oval.fill", "3"], ["rhombus.fill", "3"],
  ]

  public var fourColumnGrid = [
    GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()),
  ]

  var body: some View {
    VStack {
      Group {
        TextField("Input Medication Name", text: $medData.name)
          .padding(.horizontal)
        let newMed = Medication(
          name: medData.name, details: "Every Evening", format: medData.format,
          color: color,
          shape: medData.shape, engraving: medData.engraving, dosage: Double(1),
          history: [])
        HStack {
          MedImage(med: newMed)
            .frame(width: 75, height: 75)
        }

        Picker("Medication Format", selection: $medData.format) {
          ForEach(Medication.Format.allCases) { med in
            Text(med.name).tag(med)
          }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
      }
      Divider()

      switch medData.format {
      case .tablet:
        TabletOptions(medData: $medData, color: $color)
      case .capsule:
        CapsuleOptions(medData: $medData, color: $color)
      case .liquid:
        LiquidOptions(medData: $medData, color: $color)
      }
    }
  }

  func calcPaddingForEngraving(engraving: String) -> CGFloat {
    let stringLength = engraving.count
    return CGFloat(105 - stringLength)
  }
}

struct NewMedicationView_Previews: PreviewProvider {
  static var previews: some View {
    NewMedicationView(
      medData: .constant(Medication.data[0].data), color: .constant([Color(.systemGreen)]))
  }
}

//
//  MedicationOptions.swift
//  MedsMinder
//
//  Created by Renee Berger on 11/24/21.
//

import SwiftUI

struct TabletOptions: View {
  @Binding var medData: Medication.Data
  @Binding var color: [Color]  // TODO: Let's do better than an array here

  var medShapes: [[String]] = [
    ["circle.fill", "3"], ["circle.fill", "2"], ["circle.fill", "1"], ["capsule.fill", "3"],
    ["capsule.fill", "1"], ["oval.fill", "2"], ["oval.fill", "3"], ["rhombus.fill", "3"],
  ]

  public var fourColumnGrid = [
    GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()),
  ]

  var body: some View {
    ScrollView {
      HStack {
        Spacer()
        ColorPicker("Pill color", selection: $color[0], supportsOpacity: false)
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
            let shape = $0[0]  // TODO: Let's do better here with structured data
            let size = $0[1]
            let selected: Bool = medData.shape == [shape, size]
            Button(action: {
              medData.shape = [shape, size]
            }) {
              ZStack {
                Image(systemName: shape)
                  .foregroundColor(.white)
                  .font(.title)
                  .imageScale(
                    size == "3" ? .large : size == "1" ? .small : .medium)
                Image(systemName: "\(shape)")
                  .foregroundColor(.gray)
                  .font(.largeTitle)
                  .imageScale(
                    // TODO: Use enum instead of "1" and "3"
                    size == "3" ? .large : size == "1" ? .small : .medium
                  )
                  .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 0)
                  .padding(12)
              }
              .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                  .strokeBorder(
                    selected ? Color(.systemGray3) : Color.white, lineWidth: 3)
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
        TextField("ABC", text: $medData.engraving).lineLimit(1)
          .foregroundColor(.primary)
          .multilineTextAlignment(.center)
          .font(.title)
          .padding()
          .overlay(
            Capsule()
              .stroke(Color(.systemGray3), lineWidth: 3)
          )
          .padding(
            .horizontal, calcPaddingForEngraving(engraving: self.medData.engraving))
      }
    }
  }

  func calcPaddingForEngraving(engraving: String) -> CGFloat {
    let stringLength = engraving.count
    return CGFloat(105 - stringLength)
  }

  func updateSecondColor(newColor: Color) {
    color[1] = newColor
  }
}

struct CapsuleOptions: View {
  @Binding var medData: Medication.Data
  @Binding var color: [Color]

  var body: some View {
    ScrollView {
      HStack {
        Spacer()
        ColorPicker("Left Capsule Color", selection: $color[0], supportsOpacity: false)
          .padding(.horizontal)
      }
      HStack {
        Spacer()
        ColorPicker("Right Capsule Color", selection: $color[1], supportsOpacity: false)
          .padding(.horizontal)
      }

      Divider()

      Group {
        HStack {
          Text("Engraving")
            .fontWeight(.bold)
            .padding()
          Spacer()
        }
        TextField("ABC", text: $medData.engraving).lineLimit(1)
          .foregroundColor(.primary)
          .multilineTextAlignment(.center)
          .font(.title)
          .padding()
          .overlay(
            Capsule()
              .stroke(Color(.systemGray3), lineWidth: 3)
          )
          .padding(
            .horizontal, calcPaddingForEngraving(engraving: self.medData.engraving))
      }
    }
  }

  func calcPaddingForEngraving(engraving: String) -> CGFloat {
    let stringLength = engraving.count
    return CGFloat(105 - stringLength)
  }
}

struct LiquidOptions: View {
  @Binding var medData: Medication.Data
  @Binding var color: [Color]

  var body: some View {
    ScrollView {
      HStack {
        Spacer()
        ColorPicker("Liquid color", selection: $color[0], supportsOpacity: false)
          .padding(.horizontal)
      }
      Divider()
    }
  }
}

// MARK: - Previews

struct TabletOptions_Previews: PreviewProvider {
  static var previews: some View {
    TabletOptions(
      medData: .constant(Medication.data[0].data),
      color: .constant([Color(.systemGreen), Color(.white)])
    )
    .previewLayout(.sizeThatFits)
  }
}

struct CapsuleOptions_Previews: PreviewProvider {
  static var previews: some View {
    CapsuleOptions(
      medData: .constant(Medication.data[0].data),
      color: .constant([Color(.systemGreen), Color(.white)])
    ).previewLayout(.sizeThatFits)
  }
}

struct LiquidOptions_Preview: PreviewProvider {
  static var previews: some View {
    LiquidOptions(
      medData: .constant(Medication.data[0].data),
      color: .constant([Color(.systemGreen), Color(.white)])
    ).previewLayout(.sizeThatFits)
  }
}

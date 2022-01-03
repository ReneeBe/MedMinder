//
//  MedImage.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/15/21.
//

import SwiftUI
import UIKit

struct MedImage: View {
  var med: Medication

  var body: some View {
    let attrs =
      [
        NSAttributedString.Key.foregroundColor: colorDarknessCalculator(
          color: med.color[0] ?? Color.yellow) == true
          ? UIColor.black.withAlphaComponent(0.2) : UIColor.white.withAlphaComponent(0.4),
        NSAttributedString.Key.textEffect:
          NSAttributedString.TextEffectStyle.letterpressStyle
          as NSString,
      ] as [NSAttributedString.Key: Any]

    // TODO: Break these out into different view classes
    switch med.format {
    case .capsule:
      ZStack {
        Image(systemName: "capsule.lefthalf.filled")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundColor(med.color[0])
          .shadow(radius: 2)
        Image(systemName: "capsule.righthalf.filled")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundColor(med.color[1])
          .shadow(radius: 2)
      }
      .overlay(
        AttributedText(getString(string: med.engraving, attrs: attrs))
          .scaledToFit()
      )
    case .liquid:
      Image(systemName: "drop.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundColor(med.color[0])
        .shadow(radius: 2)
        .shadow(radius: 2)
    case .tablet:
      Image(systemName: med.shape[0] != "" ? med.shape[0] : "pills")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundColor(med.color[0])
        .shadow(radius: 2)
        .shadow(radius: 2)
        .overlay(
          AttributedText(getString(string: med.engraving, attrs: attrs))
            .scaledToFit()
        )
    }
  }

  func getString(string: String, attrs: [NSAttributedString.Key: Any]) -> NSAttributedString {
    return NSAttributedString(string: string, attributes: attrs)
  }

  // TODO: Break color utils out into a different class
  func colorDarknessCalculator(color: Color) -> Bool {
    let stringified = StringFromColor(color: color)
    let isDark = isLightColor(red: stringified[0], green: stringified[1], blue: stringified[2])
    return isDark
  }

  func isLightColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> Bool {
    let lightRed = red > 0.65
    let lightGreen = green > 0.65
    let lightBlue = blue > 0.65

    let lightness = [lightRed, lightGreen, lightBlue].reduce(0) { $1 ? $0 + 1 : $0 }
    return lightness >= 2
  }

  func StringFromColor(color: Color) -> [CGFloat] {
    var components = color.cgColor?.components
    if components == nil {
      components = Color(.red).cgColor?.components
    }
    return components!
  }
}

// TODO: Break this out into a seperate class
struct AttributedText: View {
  @State private var size: CGSize = .zero

  let attributedString: NSAttributedString

  init(_ attributedString: NSAttributedString) {
    self.attributedString = attributedString
  }

  var body: some View {
    AttributedTextRepresentable(attributedString: attributedString, size: $size)
      .frame(width: size.width, height: size.height)
  }

  struct AttributedTextRepresentable: UIViewRepresentable {

    let attributedString: NSAttributedString
    @Binding var size: CGSize

    func makeUIView(context: Context) -> UILabel {
      let label = UILabel()

      label.lineBreakMode = .byClipping
      label.numberOfLines = 0

      return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
      uiView.attributedText = attributedString

      DispatchQueue.main.async {
        size = uiView.sizeThatFits(uiView.superview?.bounds.size ?? .zero)
      }
    }
  }
}

struct MedImage_Previews: PreviewProvider {
  static var medOne: Medication = Medication.data[1]
  static var medTwo: Medication = Medication.data[2]

  static var previews: some View {
    Group {
      HStack {
        MedImage(med: medOne).frame(width: 60, height: 60)
          .padding(.trailing)
        Spacer()
      }
      .padding()
      HStack {
        MedImage(med: medTwo).frame(width: 60, height: 60).padding(.trailing)
        Spacer()
      }
      .padding()
    }
    .previewLayout(.sizeThatFits)
  }
}

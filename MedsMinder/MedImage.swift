//
//  MedImage.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/15/21.
//

import SwiftUI
import UIKit

struct MedImage: View {
    var med: Med

    var body: some View {
        let attrs = [
            NSAttributedString.Key.foregroundColor: colorDarknessCalculator(color: med.color[0] ?? Color.yellow) == true ? UIColor.black.withAlphaComponent(0.2) : UIColor.white.withAlphaComponent(0.4),
            NSAttributedString.Key.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle as NSString
        ] as [NSAttributedString.Key : Any]
        
        if med.format == "capsule" {
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
        } else if med.format == "liquid" {
            Image(systemName: "drop.fill")
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .foregroundColor(med.color[0])
                 .shadow(radius: 2)
                 .background(
                    Image(systemName: med.shape[0])
                        .foregroundColor(Color(.systemGray))
                        .shadow(radius: 1)
                 )
        } else {
            Image(systemName: med.shape[0] != "" ? med.shape[0] : "pills")
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .foregroundColor(med.color[0])
                 .shadow(radius: 2)
                 .background(
                    Image(systemName: med.shape[0])
                        .foregroundColor(Color(.systemGray))
                        .shadow(radius: 1)
                 )
                 .overlay(
                    AttributedText(getString(string: med.engraving, attrs: attrs))
                        .scaledToFit()
                 )
        }
    }

    func getString(string: String, attrs: [NSAttributedString.Key : Any]) -> NSAttributedString {
        return NSAttributedString(string: string, attributes: attrs)
    }

    func colorDarknessCalculator(color: Color) -> Bool {
//        print(color)
        let stringified = StringFromColor(color: color)
//        print("hello renee this is stringified: \(stringified)")
        let isDark = isLightColor(red: stringified[0], green: stringified[1], blue: stringified[2])
//        print("hello renee from colordarknesscalculator! \(isDark)")
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
//        print("we are in stringFromColor:")
//        print(components as Any)
        if components == nil {
            components = Color(.red).cgColor?.components
        }
        return components!
//        return "\(components![0]),\(components![1]),\(components![2]),\(components![3])"
    }


}

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
    static var medOne: Med = Med.data[1]

    static var previews: some View {
        ZStack{
            MedImage(med: medOne)
        }
    }
}

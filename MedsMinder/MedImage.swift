//
//  MedImage.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/15/21.
//

import SwiftUI
import UIKit

//struct MedImage: View {
//    var med: Med
//
//    var body: some View {
//        let attrs = [
////                    NSAttributedString.Key.foregroundColor: UIColor.gray,
//            NSAttributedString.Key.foregroundColor: colorDarknessCalculator(color: med.color ?? Color.yellow) == true ? UIColor.black.withAlphaComponent(0.2) : UIColor.white.withAlphaComponent(0.4),
////            NSAttributedString.Key.foregroundColor: colorDarknessCalculator(color: med.color ?? Color.yellow) == true ? UIColor.black : UIColor.white,
//    //      NSAttributedString.Key.font: UIFont(name: "Georgia-Bold", size: 24)!,
//            NSAttributedString.Key.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle as NSString
//        ] as [NSAttributedString.Key : Any]
////        let engraving.attributedText = string
//
//        AttributedText(getString(string: med.engraving != "" ? med.engraving : "   ", attrs: attrs))
////            .resizable()
////            .aspectRatio(contentMode: .fit)
//            .scaledToFit()
//            .padding()
//            .background(
//                Image(systemName: med.shape[0] != "" ? med.shape[0] : "pills")
//                     .resizable()
//                     .aspectRatio(contentMode: .fit)
//                     .foregroundColor(med.color)
//                     .shadow(radius: 2)
//        //             .shadow(color: .gray, radius: 5)
//                     .background(
//                        Image(systemName: med.shape[0])
//                            .foregroundColor(Color(.systemGray))
//                            .shadow(radius: 1)
//                     )
//                    .border(.blue)
//            )
////            .padding(1)
//            .frame(maxWidth: 75, maxHeight: 75)
//            .border(.green)
//    }
//
//    func getString(string: String, attrs: [NSAttributedString.Key : Any]) -> NSAttributedString {
//        return NSAttributedString(string: string, attributes: attrs)
//    }
//
//    func colorDarknessCalculator(color: Color) -> Bool {
//        print(color)
//        let stringified = StringFromColor(color: color)
//        print("hello renee this is stringified: \(stringified)")
//        let isDark = isLightColor(red: stringified[0], green: stringified[1], blue: stringified[2])
//        print("hello renee from colordarknesscalculator! \(isDark)")
//        return isDark
////        print(color)
////        return color.accessibleFontColor(color)
////        return isLightColor(red: Color.red, green: Color.green, blue: Color.blue)
////        return UIColor(color)
////        return true
//    }
//
//    func isLightColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> Bool {
//        let lightRed = red > 0.65
//        let lightGreen = green > 0.65
//        let lightBlue = blue > 0.65
//
//        let lightness = [lightRed, lightGreen, lightBlue].reduce(0) { $1 ? $0 + 1 : $0 }
//        return lightness >= 2
//    }
//
////    return Color(.sRGB, red: red, green: green, blue: blue, opacity: 1)
//
//
//    func StringFromColor(color: Color) -> [CGFloat] {
//        let components = color.cgColor?.components
//        print("we are in stringFromColor:")
//        print(components as Any)
////        if components == nil {
////            components = color.getRed(color)
////        }
//        return components!
////        return "\(components![0]),\(components![1]),\(components![2]),\(components![3])"
//    }
//
//
//}
//
//struct AttributedText: View {
//    @State private var size: CGSize = .zero
////    var attr: AttributedStringProtocol
//
//
//    let attributedString: NSAttributedString
//
//    init(_ attributedString: NSAttributedString) {
//        self.attributedString = attributedString
//    }
//
//    var body: some View {
//        AttributedTextRepresentable(attributedString: attributedString, size: $size)
//            .frame(width: size.width, height: size.height)
//    }
//
//    struct AttributedTextRepresentable: UIViewRepresentable {
//
//        let attributedString: NSAttributedString
//        @Binding var size: CGSize
//
//        func makeUIView(context: Context) -> UILabel {
//            let label = UILabel()
//
//            label.lineBreakMode = .byClipping
//            label.numberOfLines = 0
//
//            return label
//        }
//
//        func updateUIView(_ uiView: UILabel, context: Context) {
//            uiView.attributedText = attributedString
//
//            DispatchQueue.main.async {
//                size = uiView.sizeThatFits(uiView.superview?.bounds.size ?? .zero)
//            }
//        }
//    }
//}


struct MedImage: View {
    var med: Med





    var body: some View {
        let attrs = [
//                    NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.foregroundColor: colorDarknessCalculator(color: med.color ?? Color.yellow) == true ? UIColor.black.withAlphaComponent(0.2) : UIColor.white.withAlphaComponent(0.4),
//            NSAttributedString.Key.foregroundColor: colorDarknessCalculator(color: med.color ?? Color.yellow) == true ? UIColor.black : UIColor.white,
    //      NSAttributedString.Key.font: UIFont(name: "Georgia-Bold", size: 24)!,
            NSAttributedString.Key.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle as NSString
        ] as [NSAttributedString.Key : Any]
//        let engraving.attributedText = string


        Image(systemName: med.shape[0] != "" ? med.shape[0] : "pills")
             .resizable()
             .aspectRatio(contentMode: .fit)
//             .scaledToFit()
             .foregroundColor(med.color)
//             .frame(width: 75, height: 75)
             .shadow(radius: 2)
//             .shadow(color: .gray, radius: 5)
             .background(
                Image(systemName: med.shape[0])
                    .foregroundColor(Color(.systemGray))
                    .shadow(radius: 1)
             )
             .overlay(
//                Label(getString(string: med.engraving))
                AttributedText(getString(string: med.engraving, attrs: attrs))
                    .scaledToFit()
//                    .aspectRatio(contentMode: .fit)
//                            .shadow(color: Color.white, radius: 2)
//                            .shadow(color: Color.white, radius: 1)
             )
    }

    func getString(string: String, attrs: [NSAttributedString.Key : Any]) -> NSAttributedString {
        return NSAttributedString(string: string, attributes: attrs)
    }

    func colorDarknessCalculator(color: Color) -> Bool {
        print(color)
        let stringified = StringFromColor(color: color)
        print("hello renee this is stringified: \(stringified)")
        let isDark = isLightColor(red: stringified[0], green: stringified[1], blue: stringified[2])
        print("hello renee from colordarknesscalculator! \(isDark)")
        return isDark
//        print(color)
//        return color.accessibleFontColor(color)
//        return isLightColor(red: Color.red, green: Color.green, blue: Color.blue)
//        return UIColor(color)
//        return true
    }

    func isLightColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> Bool {
        let lightRed = red > 0.65
        let lightGreen = green > 0.65
        let lightBlue = blue > 0.65

        let lightness = [lightRed, lightGreen, lightBlue].reduce(0) { $1 ? $0 + 1 : $0 }
        return lightness >= 2
    }

//    return Color(.sRGB, red: red, green: green, blue: blue, opacity: 1)


    func StringFromColor(color: Color) -> [CGFloat] {
        let components = color.cgColor?.components
        print("we are in stringFromColor:")
        print(components as Any)
//        if components == nil {
//            components = color.getRed(color)
//        }
        return components!
//        return "\(components![0]),\(components![1]),\(components![2]),\(components![3])"
    }


}

struct AttributedText: View {
    @State private var size: CGSize = .zero
//    var attr: AttributedStringProtocol


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
//            RoundedRectangle()
            MedImage(med: medOne)

            
        }
    }
}

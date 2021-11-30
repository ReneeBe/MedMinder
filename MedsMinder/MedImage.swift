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
    let attrs = [
        NSAttributedString.Key.foregroundColor: UIColor.gray,
//      NSAttributedString.Key.font: UIFont(name: "Georgia-Bold", size: 24)!,
        NSAttributedString.Key.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle as NSString
    ]
    

    

    var body: some View {
//        let engraving.attributedText = string

        Image(systemName: med.shape[0] != "" ? med.shape[0] : "pills")
             .resizable()
             .scaledToFit()
             .foregroundColor(med.color)
//             .frame(width: 75, height: 75)
             .shadow(color: .gray, radius: 2)
             .shadow(color: .gray, radius: 5)
             .background(
                Image(systemName: med.shape[0])
                    .foregroundColor(Color(.systemGray))
                    .shadow(radius: 1)

             )
             .overlay(
//                Label(getString(string: med.engraving))
                AttributedText(getString(string: med.engraving))
//                            .shadow(color: Color.white, radius: 2)
//                            .shadow(color: Color.white, radius: 1)
             )
    }
    func getString(string: String) -> NSAttributedString {
        return NSAttributedString(string: string, attributes: attrs)

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

//struct MedImage: View {
//    var med: Med
//
//    var body: some View {
//        Image(systemName: med.shape[0])
////            .resizable()
////            .scaledToFit()
//            .foregroundColor(med.color)
//            .font(Font.largeTitle.weight(.ultraLight))
//            .background(
//                    Image(systemName: med.shape[0])
//                        .foregroundColor(Color(.systemGray))
//                        .font(Font.largeTitle.weight(.black))
//                        .shadow(color: .gray, radius: 3)
//            )
////            .resizable()
////            .scaledToFit()
//            .overlay(
//                Text(med.engraving)
//                    .padding(5)
////                    .scaledToFill()
//                    .scaledToFit()
////                    .font()
//                    .foregroundColor(Color(.systemGray))
////                    .shadow(color: .pink, radius: 20)
//
//                    .shadow(color: Color(.systemGray), radius: 20)
//            )
//
//    }
//}





struct MedImage_Previews: PreviewProvider {
    static var medOne: Med = Med.data[1]

    static var previews: some View {
        ZStack{
//            RoundedRectangle()
            MedImage(med: medOne)

            
        }
    }
}

////
////  zigZagRectangle.swift
////  MedsMinder
////
////  Created by Renee Berger on 11/30/21.
////
//
//import SwiftUI
//
//struct zigZagRectangle: View {
//    var body: some View {
//        ZStack{
//            Rectangle()
//                .frame(width: 135, height: 67)
//                .padding(.bottom, 67)
//                .mask(
//                    Group{
//                        HStack {
//                            Image(systemName: "chevron.up").padding(.leading, -13)
//                            Image(systemName: "chevron.up").padding(.leading, -13)
//                            Image(systemName: "chevron.up").padding(.leading, -13)
//                            Image(systemName: "chevron.up").padding(.leading, -13)
//                            Image(systemName: "chevron.up").padding(.leading, -13)
//                            Image(systemName: "chevron.up").padding(.leading, -13)
//                            Image(systemName: "chevron.up").padding(.leading, -13)
//                            Image(systemName: "chevron.up").padding(.leading, -13)
//                            Image(systemName: "chevron.up").padding(.leading, -13)
//                            Image(systemName: "chevron.up").padding(.leading, -13)
//                        }
//                    }
//                    .padding(.trailing, -13)
//
//
//
//                )
//
//        }
//        .foregroundColor(.white)
//
//    }
//}
//
//struct zigZagRectangle_Previews: PreviewProvider {
//    static var medOne: Med = Med.data[1]
//    
//    static var previews: some View {
//        MedImage(med: medOne)
//            .overlay(zigZagRectangle())
////            .mask(zigZagRectangle().padding(.top, 175))
////        zigZagRectangle()
//    }
//}

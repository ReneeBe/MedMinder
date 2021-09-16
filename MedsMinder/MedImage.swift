//
//  MedImage.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/15/21.
//

import SwiftUI

struct MedImage: View {
    var med: Med
    
    var body: some View {
        Image(systemName: med.shape[0])
            .foregroundColor(med.color)
            .font(.largeTitle)
//            .imageScale(.large)
            .foregroundColor(med.color)
            .background(Circle().strokeBorder(Color(.systemGray), lineWidth: 3))
            .overlay(Text(med.engraving))
    }
    
}



struct MedImage_Previews: PreviewProvider {
    static var medOne: Med = Med.data[1]

    static var previews: some View {
        MedImage(med: medOne)
    }
}

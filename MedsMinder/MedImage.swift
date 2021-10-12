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
            .font(Font.largeTitle.weight(.ultraLight))
            .background(
                    Image(systemName: med.shape[0])
                        .foregroundColor(Color(.systemGray))
                        .font(Font.largeTitle.weight(.black))
            )
            .overlay(
                Text(med.engraving)
                    .font(.callout)
                    .foregroundColor(Color(.systemGray))
            )
    }
}





struct MedImage_Previews: PreviewProvider {
    static var medOne: Med = Med.data[1]

    static var previews: some View {
        MedImage(med: medOne)
    }
}

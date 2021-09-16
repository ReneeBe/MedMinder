//
//  ProgressBar.swift
//  MedsMinder
//
//  Created by Renee Berger on 9/3/21.
//

import SwiftUI

struct TimerPiece: Shape {
    var start: Angle
    var end: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)
        path.addArc(center: center, radius: rect.midX, startAngle: start, endAngle: end, clockwise: false)
        return path
    }
}


struct ProgressBar: View {
    var progress: Double
    
    var body: some View {
            TimerPiece(start: .degrees(45), end: .degrees(progress))
                .frame(width: 35, height: 35)
                .foregroundColor(Color(.systemBlue))
//                .padding()
                .background(
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 43, height: 43)
                )
                .padding()
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(progress: 270)
    }
}

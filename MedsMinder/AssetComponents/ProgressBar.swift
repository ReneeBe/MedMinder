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
    path.addRelativeArc(center: center, radius: rect.midX, startAngle: start, delta: end)
    return path
  }
}

struct ProgressBar: View {
  var progress: Double

  var body: some View {
    TimerPiece(start: .degrees(270), end: .degrees(progessToDegrees(progress: progress)))
      .frame(width: 35, height: 35)
      .foregroundColor(Color(.systemBlue))
      .background(
        Circle()
          .fill(Color(.systemGray5))
          .frame(width: 43, height: 43)
      )
      .padding()
  }

  func progessToDegrees(progress: Double) -> Double {
    (progress * 360)  // convert from 0-1 to degrees.
  }
}

struct ProgressBar_Previews: PreviewProvider {
  static var previews: some View {
    HStack {
      ProgressBar(progress: 0)
      ProgressBar(progress: 0.25)
      ProgressBar(progress: 0.5)
      ProgressBar(progress: 0.75)
      ProgressBar(progress: 1.0)
    }
  }
}

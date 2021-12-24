//
//  File.swift
//  MedsMinder
//
//  Created by Renee Berger on 12/30/21.
//

import Foundation
import SwiftUI
import UIKit

struct ColorUtils {
  static func StringFromColor(color: Color) -> String {
    let components = color.cgColor?.components
    return "\(components![0]),\(components![1]),\(components![2]),\(components![3])"
  }

  static func ColorFromString(string: String) -> Color {
    let components = string.components(separatedBy: ",")
    return Color(
      .sRGB,
      red: CGFloat((components[0] as NSString).floatValue),
      green: CGFloat((components[1] as NSString).floatValue),
      blue: CGFloat((components[2] as NSString).floatValue),
      opacity: 1)
  }

  static func MakeColors(colors: [String]) -> [Color] {
    var colorArray: [Color] = []
    for color in colors {
      colorArray.append(ColorFromString(string: color))
    }
    return colorArray
  }
}

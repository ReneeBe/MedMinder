//
//  UIColor.swift
//  MedsMinder
//
//  Created by Renee Berger on 11/12/21.
//

import Foundation
import SwiftUI

public extension UIColor {

    class func StringFromUIColor(color: UIColor) -> String {
        let components = color.cgColor.components
        return "[\(components![0]), \(components![1]), \(components![2]), \(components![3])"
    }
    

    
    class func UIColorFromString(string: String) -> UIColor {
        let componentsString: String = string
        componentsString.dropFirst(1)
        componentsString.dropLast(1)
        let components = componentsString.components(separatedBy: ",")
        
        return UIColor(red: CGFloat((components[0] as NSString).floatValue),
                     green: CGFloat((components[1] as NSString).floatValue),
                      blue: CGFloat((components[2] as NSString).floatValue),
                     alpha: CGFloat((components[3] as NSString).floatValue))
    }
    
}

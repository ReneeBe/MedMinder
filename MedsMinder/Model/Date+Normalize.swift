//
//  Date+Normalize.swift
//  MedsMinder
//
//  Created by Renee Berger on 12/30/21.
//

import Foundation

extension Date {
  func normalize() -> Date {
    let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    let selfComponents = Calendar.current.dateComponents([.hour, .minute], from: self)
    let normalizedComponents = DateComponents(
      calendar: Calendar.current, year: todayComponents.year,
      month: todayComponents.month,
      day: todayComponents.day, hour: selfComponents.hour,
      minute: selfComponents.minute)
    return Calendar.current.date(from: normalizedComponents) ?? Date()
  }
}

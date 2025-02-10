//
//  Utils.swift
//  LiveTimerActivity
//
//  Created by Navin Kumar on 15/01/25.
//
import Foundation

class Utils {
  static func getExactTime(from startDate: Date, to endDate: Date = Date()) -> String {
    let elapsed = Int(endDate.timeIntervalSince(startDate))
    let hours = elapsed / 3600
    let minutes = (elapsed % 3600) / 60
    let seconds = elapsed % 60
    
    if hours > 0 {
      return String(format: "%d hr, %d min, %d secs", hours, minutes, seconds)
    } else if minutes > 0 {
      return String(format: "%d min, %d secs", minutes, seconds)
    } else {
      return String(format: "%d secs", seconds)
    }
  }
}

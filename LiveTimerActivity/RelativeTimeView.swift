//
//  RelativeTimeView.swift
//  LiveTimerActivity
//
//  Created by Navin Kumar on 10/01/25.
//


import SwiftUI

struct RelativeTimeView: View {
  @State private var isPaused = false
  @State private var pauseDate: Date?
  @State private var adjustedStartDate: Date
  
  init() {
    _adjustedStartDate = State(initialValue: Date())
  }
  
  var body: some View {
    VStack(spacing: 20) {
      if isPaused {
        // Show frozen exact time when paused
        Text(getExactTime(from: adjustedStartDate))
      } else {
        // Show dynamic relative time when running
        Text(adjustedStartDate, style: .relative)
      }
      
      HStack(spacing: 20) {
        Button(action: {
          if isPaused {
            // Resume: Adjust the start date by adding the paused duration
            if let pauseDate = pauseDate {
              let pausedDuration = Date().timeIntervalSince(pauseDate)
              adjustedStartDate = adjustedStartDate.addingTimeInterval(pausedDuration)
            }
          } else {
            // Pause: Capture the current pause time
            pauseDate = Date()
          }
          isPaused.toggle()
        }) {
          Text(isPaused ? "Resume" : "Pause")
            .padding()
            .background(isPaused ? Color.green : Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
      }
    }
    .padding()
  }
  
  /// Custom function to get the exact time string in `XX min, XX secs` format
  func getExactTime(from startDate: Date) -> String {
    let elapsed = Int(Date().timeIntervalSince(startDate))
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

struct RelativeTimeView_Previews: PreviewProvider {
  static var previews: some View {
    RelativeTimeView()
  }
}

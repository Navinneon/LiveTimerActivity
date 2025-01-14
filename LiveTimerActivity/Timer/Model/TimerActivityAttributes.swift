//
//  TimerActivityAttributes.swift
//  LiveTimerActivity
//
//  Created by Navin Kumar on 14/01/25.
//

import SwiftUI
import ActivityKit

// MARK: - TimerActivityAttributes

struct TimerActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var isPaused: Bool = false
    var pauseDate: Date?
    var adjustedStartDate: Date
  }
  var timerName: String
}

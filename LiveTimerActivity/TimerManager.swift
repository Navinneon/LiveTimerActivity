//
//  TimerActivityAttributes.swift
//  LiveTimerActivity
//
//  Created by Navin Kumar on 01/12/24.
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

@MainActor
class TimerManager: ObservableObject {
  static let shared = TimerManager()
  
  @Published var isPaused: Bool = false
  @Published var isTimerRunning: Bool = false
  @Published var pauseDate = Date()
  @Published var adjustedStartDate = Date()
  
  var activity: Activity<TimerActivityAttributes>?
  
  func startTimerActivity(timerName: String) {
    if ActivityAuthorizationInfo().areActivitiesEnabled {
      let attributes = TimerActivityAttributes(timerName: timerName)
      pauseDate = Date()
      adjustedStartDate = Date()
      let contentState = TimerActivityAttributes.ContentState(isPaused: false, adjustedStartDate: Date())
      
      do {
        let activity = try Activity<TimerActivityAttributes>.request(
          attributes: attributes,
          content: .init(state: contentState, staleDate: nil),
          pushType: nil
        )
        self.activity = activity
        isTimerRunning = true
        isPaused = false
      } catch {
        print("Failed to start activity: \(error.localizedDescription)")
      }
    }
  }
  
  func stopTimerActivity() async {
    guard let activity = activity else { return }
    
    let endContent = TimerActivityAttributes.ContentState(isPaused: true, adjustedStartDate: Date())
    await activity.end(ActivityContent(state: endContent, staleDate: nil), dismissalPolicy: .immediate)
    
    isTimerRunning = false
    
    print("Live Activity ended.")
  }
  
  func togglePause() {
    isPaused.toggle()
    
    DispatchQueue.main.async {
      Task {
        await self.updateActivityState()
      }
    }
  }
  
  func updateActivityState() async {
    guard let activity = activity else { return }
    if isPaused {
      pauseDate = Date()
    } else {
      // Pause: Capture the current pause time
      let pausedDuration = Date().timeIntervalSince(pauseDate)
      adjustedStartDate = adjustedStartDate.addingTimeInterval(pausedDuration)
    }
    let updatedState = TimerActivityAttributes.ContentState(isPaused: isPaused,
                                                            pauseDate: pauseDate,
                                                            adjustedStartDate: adjustedStartDate)
    await activity.update(using: updatedState)
  }
}

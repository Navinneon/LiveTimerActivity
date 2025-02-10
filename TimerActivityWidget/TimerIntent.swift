//
//  StopTimerIntent.swift
//  LiveTimerActivity
//
//  Created by Navin Kumar on 14/01/25.
//


import AppIntents
import CoreData
import ActivityKit

struct PlayPauseTimerIntent: LiveActivityIntent {
  static var title: LocalizedStringResource = "Play/Pause Timer"
  
  @Parameter(title: "Timer Name")
  var timerName: String?
  
  init() {}
  
  init(timerName: String) {
    self.timerName = timerName
  }
  
  func perform() async throws -> some IntentResult {
    guard let timerName = timerName else {
      throw NSError(domain: "PlayPauseTimerIntentError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Timer name is missing"])
    }
    
    // Fetch timer from Core Data
    let timerManager = TimerDataManager.shared
    guard let timer = timerManager.fetchTimer(for: timerName) else {
      throw NSError(domain: "PlayPauseTimerIntentError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Timer not found"])
    }
    
    let isPaused = !timer.isPaused
    let newPauseDate = isPaused ? Date() : nil
    
    let updatedAdjustedStartDate: Date
    if isPaused {
      updatedAdjustedStartDate = timer.adjustedStartDate ?? Date()
    } else {
      // Calculate how much time was paused and adjust the start date
      let pausedDuration = Date().timeIntervalSince(timer.pauseDate ?? Date())
      updatedAdjustedStartDate = (timer.adjustedStartDate ?? Date()).addingTimeInterval(pausedDuration)
    }
    
    // Update Core Data
    timerManager.createOrUpdateTimer(
      name: timerName,
      isPaused: isPaused,
      pauseDate: newPauseDate,
      adjustedStartDate: updatedAdjustedStartDate,
      activityID: timer.activityID
    )
    
    // Update Live Activity
    if let existingActivity = Activity<TimerActivityAttributes>.activities.first(
      where: { $0.attributes.timerName == timerName }
    ) {
      let updatedState = TimerActivityAttributes.ContentState(
        isPaused: isPaused,
        pauseDate: newPauseDate,
        adjustedStartDate: updatedAdjustedStartDate
      )
      await existingActivity.update(ActivityContent(state: updatedState, staleDate: nil))
    } else {
      print("No Live Activity found for \(timerName)")
    }
    
    return .result()
  }
}

@available(iOS 16.0, *)
struct StopTimerIntent: LiveActivityIntent {
  static var title: LocalizedStringResource = "Stop Timer"
  
  @Parameter(title: "Timer Name")
  var timerName: String?
  
  init() {}
  
  init(timerName: String) {
    self.timerName = timerName
  }
  
  func perform() async throws -> some IntentResult {
    guard let timerName = timerName else {
      throw NSError(domain: "StopTimerIntentError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Timer name is missing"])
    }
    
    if let activity = Activity<TimerActivityAttributes>.activities.first(where: { $0.attributes.timerName == timerName }) {
      let endContent = TimerActivityAttributes.ContentState(
        isPaused: true,
        adjustedStartDate: Date()
      )
      await activity.end(ActivityContent(state: endContent, staleDate: nil), dismissalPolicy: .immediate)
    } else {
      print("No active timer found for \(timerName)")
    }
    
    // Remove timer from Core Data
    TimerDataManager.shared.deleteTimer(name: timerName)
    
    return .result()
  }
}


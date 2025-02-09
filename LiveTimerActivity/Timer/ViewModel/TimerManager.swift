//
//  TimerActivityAttributes.swift
//  LiveTimerActivity
//
//  Created by Navin Kumar on 01/12/24.
//

import SwiftUI
import ActivityKit

@MainActor
class TimerManager: ObservableObject {
  @Published var isPaused: Bool = false
  @Published var isTimerRunning: Bool = false
  @Published var pauseDate: Date?
  @Published var adjustedStartDate = Date()
  
  private var activity: Activity<TimerActivityAttributes>?
  let timerName: String
  
  init(timerName: String) {
    self.timerName = timerName
    loadExistingTimer()
  }
  
  /// Loads an existing timer if available.
  private func loadExistingTimer() {
    guard let timer = TimerDataManager.shared.fetchTimer(for: timerName) else {
      print("No existing timer found for \(timerName)")
      return
    }
    
    isPaused = timer.isPaused
    pauseDate = timer.pauseDate
    adjustedStartDate = timer.adjustedStartDate ?? Date()
    isTimerRunning = timer.activityID != nil
    
    if let activityID = timer.activityID {
      restoreLiveActivity(activityID)
    }
  }
  
  /// Attempts to restore an existing Live Activity
  private func restoreLiveActivity(_ activityID: String) {
    guard let existingActivity = Activity<TimerActivityAttributes>.activities.first(where: { $0.id == activityID }) else {
      print("Existing Live Activity not found, starting new one")
      startTimerActivity()
      return
    }
    self.activity = existingActivity
  }
  
  /// Starts a new Live Activity and creates a new timer if needed
  func startTimerActivity() {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
    
    adjustedStartDate = Date()
    pauseDate = nil
    isPaused = false
    isTimerRunning = true
    
    let attributes = TimerActivityAttributes(timerName: timerName)
    let contentState = TimerActivityAttributes.ContentState(
      isPaused: false,
      adjustedStartDate: adjustedStartDate
    )
    
    do {
      let activity = try Activity<TimerActivityAttributes>.request(
        attributes: attributes,
        content: .init(state: contentState, staleDate: nil),
        pushType: nil
      )
      self.activity = activity
      
      // **Create the timer only when starting**
      TimerDataManager.shared.createOrUpdateTimer(
        name: timerName,
        isPaused: false,
        pauseDate: nil,
        adjustedStartDate: adjustedStartDate,
        activityID: activity.id
      )
    } catch {
      print("Failed to start activity: \(error.localizedDescription)")
    }
  }
  
  /// Stops the timer and removes it from Core Data
  func stopTimerActivity() async {
    guard let activity = activity else {
      print("No active timer to stop")
      return
    }
    
    let endContent = TimerActivityAttributes.ContentState(
      isPaused: true,
      adjustedStartDate: Date()
    )
    await activity.end(ActivityContent(state: endContent, staleDate: nil), dismissalPolicy: .immediate)
    
    self.activity = nil
    isTimerRunning = false
    
    // Remove from Core Data
    TimerDataManager.shared.deleteTimer(name: timerName)
  }
  
  /// Toggles pause and updates both Live Activity and Core Data
  func togglePause() {
    isPaused.toggle()
    
    Task {
      await updateActivityState()
    }
  }
  
  /// Updates the Live Activity and Core Data
  func updateActivityState() async {
    guard let activity = self.activity else {
      print("No activity found for timer: \(timerName)")
      return
    }
    
    if isPaused {
      pauseDate = Date()
    } else {
      let pausedDuration = Date().timeIntervalSince(pauseDate ?? Date())
      adjustedStartDate = adjustedStartDate.addingTimeInterval(pausedDuration)
    }
    
    let updatedState = TimerActivityAttributes.ContentState(
      isPaused: isPaused,
      pauseDate: pauseDate,
      adjustedStartDate: adjustedStartDate
    )
    await activity.update(ActivityContent(state: updatedState, staleDate: nil))
    
    // Update Core Data
    TimerDataManager.shared.createOrUpdateTimer(
      name: timerName,
      isPaused: isPaused,
      pauseDate: pauseDate,
      adjustedStartDate: adjustedStartDate,
      activityID: activity.id
    )
  }
}

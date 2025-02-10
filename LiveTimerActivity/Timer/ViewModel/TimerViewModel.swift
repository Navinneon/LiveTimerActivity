//
//  TimerActivityAttributes.swift
//  LiveTimerActivity
//
//  Created by Navin Kumar on 01/12/24.
//

import SwiftUI
import ActivityKit

@MainActor
class TimerViewModel: ObservableObject {
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
  
  /// Loads any existing timer from Core Data and attempts to restore its Live Activity
  func loadExistingTimer() {
    guard let timer = TimerDataManager.shared.fetchTimer(for: timerName) else {
      print("No existing timer found for \(timerName), setting default values.")
      
      // Set default values when no timer is found
      isPaused = false
      pauseDate = nil
      adjustedStartDate = Date()
      isTimerRunning = false
      activity = nil
      
      return
    }
    
    // Restore timer state from Core Data
    isPaused = timer.isPaused
    pauseDate = timer.pauseDate
    adjustedStartDate = timer.adjustedStartDate ?? Date()
    isTimerRunning = false // Assume false initially
    
    // Restore an existing Live Activity if available
    if let existingActivity = Activity<TimerActivityAttributes>.activities.first(
      where: { $0.attributes.timerName == timerName }
    ) {
      print("Restoring existing Live Activity for \(timerName)")
      self.activity = existingActivity
      isTimerRunning = true
    } else {
      startTimerActivityFromSavedState(timer)
    }
  }

  /// Starts a new Live Activity using stored Core Data values
  private func startTimerActivityFromSavedState(_ timer: TimerEntity) {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
      print("Live Activities are not enabled")
      return
    }
    
    let attributes = TimerActivityAttributes(timerName: timer.timerName ?? "Unknown")
    let contentState = TimerActivityAttributes.ContentState(
      isPaused: timer.isPaused,
      adjustedStartDate: timer.adjustedStartDate ?? Date()
    )
    
    do {
      let activity = try Activity<TimerActivityAttributes>.request(
        attributes: attributes,
        content: .init(state: contentState, staleDate: nil),
        pushType: nil
      )
      self.activity = activity
      isTimerRunning = true
      print("Successfully restarted Live Activity for \(timer.timerName ?? "Unknown")")
    } catch {
      print("Failed to restart Live Activity: \(error.localizedDescription)")
    }
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
    isPaused = false
    adjustedStartDate = Date() // Reset to ensure UI updates correctly
    pauseDate = nil
    
    // Remove from Core Data
    TimerDataManager.shared.deleteTimer(name: timerName)
    
    // Notify UI to refresh
    DispatchQueue.main.async {
      self.objectWillChange.send()
    }
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
    } else if let pauseDate = pauseDate {
      let pausedDuration = Date().timeIntervalSince(pauseDate)
      adjustedStartDate = adjustedStartDate.addingTimeInterval(pausedDuration)
      self.pauseDate = nil
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

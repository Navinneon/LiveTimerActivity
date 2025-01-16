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
  @Published var pauseDate = Date()
  @Published var adjustedStartDate = Date()
  
  private var activity: Activity<TimerActivityAttributes>?
  let timerName: String
  
  init(timerName: String) {
    self.timerName = timerName
  }
  
  func startTimerActivity() {
    if ActivityAuthorizationInfo().areActivitiesEnabled {
      let attributes = TimerActivityAttributes(timerName: timerName)
      pauseDate = Date()
      adjustedStartDate = Date()
      let contentState = TimerActivityAttributes.ContentState(
        isPaused: false,
        adjustedStartDate: Date()
      )
      
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
    guard let activity = self.activity else {
      print("No activity found for timer: \(timerName)")
      return
    }
    
    let endContent = TimerActivityAttributes.ContentState(
      isPaused: true,
      adjustedStartDate: Date()
    )
    await activity.end(ActivityContent(state: endContent, staleDate: nil), dismissalPolicy: .immediate)
    self.activity = nil
    isTimerRunning = false
  }
  
  func togglePause() {
    isPaused.toggle()
    
    Task {
      await updateActivityState()
    }
  }
  
  func updateActivityState() async {
    guard let activity = self.activity else {
      print("No activity found for timer: \(timerName)")
      return
    }
    
    if isPaused {
      pauseDate = Date()
    } else {
      let pausedDuration = Date().timeIntervalSince(pauseDate)
      adjustedStartDate = adjustedStartDate.addingTimeInterval(pausedDuration)
    }
    
    let updatedState = TimerActivityAttributes.ContentState(
      isPaused: isPaused,
      pauseDate: pauseDate,
      adjustedStartDate: adjustedStartDate
    )
    await activity.update(ActivityContent(state: updatedState, staleDate: nil))
  }
}

@MainActor
class TimerManagerRegistry {
  static let shared = TimerManagerRegistry()
  private var timerManagers: [String: TimerManager] = [:]
  
  private init() {}
  
  func getTimerManager(for timerName: String) -> TimerManager {
    if let manager = timerManagers[timerName] {
      return manager
    } else {
      let newManager = TimerManager(timerName: timerName)
      timerManagers[timerName] = newManager
      return newManager
    }
  }
}

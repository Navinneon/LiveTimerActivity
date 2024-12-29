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
    var elapsedTime: Double
    var isPaused: Bool
  }
  var timerName: String
}

@MainActor
class TimerManager: ObservableObject {
  static let shared = TimerManager()
  
  @Published var elapsedTime: TimeInterval = 0
  @Published var isPaused: Bool = false
  @Published var isTimerRunning: Bool = false
  
  private var timer: Timer?
  var activity: Activity<TimerActivityAttributes>?
  
  func startTimerActivity(timerName: String) {
    if ActivityAuthorizationInfo().areActivitiesEnabled {
      let attributes = TimerActivityAttributes(timerName: timerName)
      let contentState = TimerActivityAttributes.ContentState(elapsedTime: 0, isPaused: false)
      
      do {
        let activity = try Activity<TimerActivityAttributes>.request(
          attributes: attributes,
          content: .init(state: contentState, staleDate: nil),
          pushType: nil
        )
        self.activity = activity
        startTimer()
      } catch {
        print("Failed to start activity: \(error.localizedDescription)")
      }
    }
  }
  
  func stopTimerActivity() async {
    guard let activity = activity else { return }
    
    let endContent = TimerActivityAttributes.ContentState(elapsedTime: elapsedTime, isPaused: isPaused)
    await activity.end(ActivityContent(state: endContent, staleDate: nil), dismissalPolicy: .immediate)
    
    stopTimer()
    isTimerRunning = false
    elapsedTime = 0
    isPaused = false
    
    print("Live Activity ended.")
  }
  
  func togglePause() {
    isPaused.toggle()
    
    if isPaused {
      stopTimer()
      DispatchQueue.main.async {
        Task {
          await self.updateActivityState(elapsedTime: self.elapsedTime, isPaused: self.isPaused)
        }
      }
    } else {
      startTimer()
    }
  }
  
  func updateActivityState(elapsedTime: TimeInterval, isPaused: Bool) async {
    guard let activity = activity else { return }
    let updatedState = TimerActivityAttributes.ContentState(elapsedTime: elapsedTime, isPaused: isPaused)
    await activity.update(using: updatedState)
  }
  
  func startTimer() {
    guard timer == nil else { return }
    
    isTimerRunning = true
    isPaused = false
    
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      
      DispatchQueue.main.async {
        self.elapsedTime += 1
        Task {
          await self.updateActivityState(elapsedTime: self.elapsedTime, isPaused: self.isPaused)
        }
      }
    }
  }

  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
}

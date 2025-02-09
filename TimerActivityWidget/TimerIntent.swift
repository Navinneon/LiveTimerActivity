//
//  StopTimerIntent.swift
//  LiveTimerActivity
//
//  Created by Navin Kumar on 14/01/25.
//


import AppIntents
import CoreData

import AppIntents

@available(iOS 16.0, *)
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
    
    let timerDataManager = TimerDataManager.shared
    
    // Fetch existing timer from Core Data
    if let timer = timerDataManager.fetchTimer(for: timerName) {
      timer.isPaused.toggle() // Toggle play/pause state
      timerDataManager.saveContext() // Save changes
    } else {
      throw NSError(domain: "PlayPauseTimerIntentError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Timer not found"])
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
    let timerDataManager = TimerDataManager.shared
    timerDataManager.deleteTimer(name: timerName)
    
    return .result()
  }
}

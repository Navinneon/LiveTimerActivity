//
//  StopTimerIntent.swift
//  LiveTimerActivity
//
//  Created by Navin Kumar on 14/01/25.
//


import AppIntents

@available(iOS 16.0, *)
struct StopTimerIntent: LiveActivityIntent {
  // Define the title for the intent, using a localized string.
  static var title: LocalizedStringResource = "Stop Timer"
  
  var timerName: String?
  
  init() {}
  
  init(timerName: String) {
    self.timerName = timerName
  }
  
  // Perform the action when the intent is triggered
  func perform() async throws -> some IntentResult {
    guard let timerName = timerName else {
      throw NSError(domain: "StopTimerIntentError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Timer type is missing"])
    }
    
    let timerManager = await TimerManagerRegistry.shared.getTimerManager(for: timerName)
    await timerManager.stopTimerActivity()
    return .result()
  }
}

@available(iOS 16.0, *)
struct PlayPauseTimerIntent: LiveActivityIntent {
  static var title: LocalizedStringResource = "Play/Pause Timer"
  
  @Parameter(title: "timerName")
  var timerName: String?
  
  init() {}
  
  init(timerName: String) {
    self.timerName = timerName
  }
  
  func perform() async throws -> some IntentResult {
    guard let timerName = timerName else {
      throw NSError(domain: "PlayPauseTimerIntentError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Timer name is missing"])
    }
    
    let timerManager = await TimerManagerRegistry.shared.getTimerManager(for: timerName)
    await timerManager.togglePause()
    
    
    return .result()
  }
}

//
//  StopTimerIntent.swift
//  LiveTimerActivity
//
//  Created by Navin Kumar on 29/12/24.
//


import AppIntents

@available(iOS 16.0, *)
struct StopTimerIntent: LiveActivityIntent {
  // Define the title for the intent, using a localized string.
  static var title: LocalizedStringResource = "Stop Timer"
  
  // Perform the action when the intent is triggered
  func perform() async throws -> some IntentResult {
    // Call your method to stop the timer activity
    await TimerManager.shared.stopTimerActivity()
    
    // Return success result
    return .result()
  }
}

@available(iOS 16.0, *)
struct PlayPauseTimerIntent: LiveActivityIntent {
  static var title: LocalizedStringResource = "Play/Pause Timer"
  
  func perform() async throws -> some IntentResult {
    // Await the toggle timer state
    await TimerManager.shared.togglePause()
    
    return .result()
  }
}

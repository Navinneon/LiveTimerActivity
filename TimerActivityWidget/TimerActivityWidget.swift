//
//  TimerActivityWidget.swift
//  TimerActivityWidget
//
//  Created by Navin Kumar on 30/11/24.
//

import WidgetKit
import ActivityKit
import SwiftUI

struct TimerActivityDynamicIsland: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: TimerActivityAttributes.self) { context in
      // Lock screen and expanded Dynamic Island
      VStack {
        Text(context.attributes.timerName)
          .font(.headline)
        if context.state.isPaused {
          Text(getExactTime(from: context.state.adjustedStartDate))
            .font(.title3)
        } else {
          Text(context.state.adjustedStartDate, style: .relative)
            .font(.title3)
        }
      }
      .padding()
    } dynamicIsland: { context in
      DynamicIsland {
        // Expanded Dynamic Island
        DynamicIslandExpandedRegion(.center) {
          VStack(alignment: .center, spacing: 12) {
            //            ProgressView(value: context.state.elapsedTime, total: 300)
            //              .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            //              .frame(height: 16)
            //              .cornerRadius(8)
            
            if context.state.isPaused {
              Text(getExactTime(from: context.state.adjustedStartDate))
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            } else {
              // Show dynamic relative time when running
              Text(context.state.adjustedStartDate, style: .relative)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            }
          }
          .padding(.horizontal)
        }
        DynamicIslandExpandedRegion(.bottom) {
          HStack(spacing: 20) {
            // Play/Pause button
            Button(intent: PlayPauseTimerIntent()) {
              Image(systemName: context.state.isPaused ? "play.fill" : "pause.fill")
                .font(.title2)
                .foregroundColor(.white)
            }
            
            // Stop button
            Button(intent: StopTimerIntent()) {
              Image(systemName: "stop.fill")
                .font(.title2)
                .foregroundColor(.white)
            }
          }
          .padding(.horizontal)
        }
      } compactLeading: {
        Image(systemName: context.state.isPaused ? "play.fill" : "pause.fill")
      } compactTrailing: {
        Image(systemName: "stop.fill")
      } minimal: {
        Image(systemName: "timer")
          .foregroundColor(.blue)
      }
    }
  }
  
  func getExactTime(from startDate: Date) -> String {
    let elapsed = Int(Date().timeIntervalSince(startDate))
    let hours = elapsed / 3600
    let minutes = (elapsed % 3600) / 60
    let seconds = elapsed % 60
    
    if hours > 0 {
      return String(format: "%d hr, %d min, %d secs", hours, minutes, seconds)
    } else if minutes > 0 {
      return String(format: "%d min, %d secs", minutes, seconds)
    } else {
      return String(format: "%d secs", seconds)
    }
  }
}

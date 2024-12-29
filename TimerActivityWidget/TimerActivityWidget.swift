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
        Text("\(Int(context.state.elapsedTime)) seconds elapsed")
          .font(.title3)
      }
      .padding()
    } dynamicIsland: { context in
      DynamicIsland {
        // Expanded Dynamic Island
        DynamicIslandExpandedRegion(.center) {
          VStack(spacing: 12) {
            ProgressView(value: context.state.elapsedTime, total: 300)
              .progressViewStyle(LinearProgressViewStyle(tint: .blue))
              .frame(height: 16)
              .cornerRadius(8)
            
            Text("\(Int(context.state.elapsedTime)) seconds")
              .font(.title2)
              .bold()
              .foregroundColor(.white)
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
}

//
//  TimerActivityWidget.swift
//  TimerActivityWidget
//
//  Created by Navin Kumar on 30/11/24.
//

import WidgetKit
import ActivityKit
import SwiftUI
import AppIntents

// MARK: - TimerActivityDynamicIsland Widget

struct TimerActivityDynamicIsland: Widget {
    
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: TimerActivityAttributes.self) { context in
      timerLockScreenView(context: context)
    } dynamicIsland: { context in
      DynamicIsland {
        // Expanded Dynamic Island Regions
        DynamicIslandExpandedRegion(.center) {
          timerDynamicIslandCenterView(context: context, foregroundColor: .white)
        }
        DynamicIslandExpandedRegion(.bottom) {
          timerDynamicIslandBottomView(context: context, foregroundColor: .white)
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
  
  // MARK: - Center View for Dynamic Island and Lock Screen
  
  @ViewBuilder
  func timerDynamicIslandCenterView(
    context: ActivityViewContext<TimerActivityAttributes>,
    foregroundColor: Color) -> some View {
      VStack {
        Text("Timer")
          .bold()
          .foregroundColor(foregroundColor)
        
        HStack {
          Image(systemName: "backward")
            .bold()
            .foregroundColor(foregroundColor)
            .rotationEffect(.degrees(context.state.isPaused ? 180 : 0))
          
          if context.state.isPaused {
            Text(TimerManager.shared.getExactTime(from: context.state.adjustedStartDate))
              .bold()
              .foregroundColor(foregroundColor)
              .multilineTextAlignment(.center)
          } else {
            Text(context.state.adjustedStartDate, style: .relative)
              .bold()
              .foregroundColor(foregroundColor)
              .multilineTextAlignment(.center)
          }
          
          Image(systemName: "forward")
            .bold()
            .foregroundColor(foregroundColor)
            .rotationEffect(.degrees(context.state.isPaused ? -180 : 0))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
      }
    }
  
  // MARK: - Bottom View for Dynamic Island and Lock Screen
  
  @ViewBuilder
  func timerDynamicIslandBottomView(
    context: ActivityViewContext<TimerActivityAttributes>,
    foregroundColor: Color) -> some View {
      HStack(spacing: 20) {
        // Play/Pause button
        Button(intent: PlayPauseTimerIntent()) {
          Image(systemName: context.state.isPaused ? "play.fill" : "pause.fill")
            .bold()
            .foregroundColor(foregroundColor)
        }
        
        // Stop button
        Button(intent: StopTimerIntent()) {
          Image(systemName: "stop.fill")
            .bold()
            .foregroundColor(foregroundColor)
        }
      }
      .padding(.horizontal)
    }
  
  // MARK: - Lock Screen View
  
  @ViewBuilder
  func timerLockScreenView(
    context: ActivityViewContext<TimerActivityAttributes>) -> some View {
      VStack() {
        timerDynamicIslandCenterView(context: context, foregroundColor: .black)
        timerDynamicIslandBottomView(context: context, foregroundColor: .black)
      }
      .frame(maxWidth: .infinity)
      .padding()
    }
}

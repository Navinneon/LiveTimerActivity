//
//  TimerView.swift
//  LiveTimerActivity
//
//  Created by Navin Kumar on 01/12/24.
//

import SwiftUI

struct TimerView: View {
  @StateObject private var timerManager: TimerManager
      
  init(timerType: TimerType) {
    _timerManager = StateObject(wrappedValue: TimerManager(timerName: timerType.rawValue))
  }
  
  var body: some View {
    mainView
  }
  
  private var mainView: some View {
    VStack(spacing: 20) {
      titleView
      timerStatusView
      controlButtonsView
    }
    .padding()
  }
  
  private func startTimer() {
    timerManager.startTimerActivity()
  }
  
  private func stopTimer() {
    Task {
      await timerManager.stopTimerActivity()
    }
  }
  
  private var titleView: some View {
    Text(timerManager.timerName)
      .font(.title2)
      .bold()
  }
  
  private var timerStatusView: some View {
    Group {
      if !timerManager.isTimerRunning {
        Text(Utils.getExactTime(from: Date()))
          .font(.title)
      } else if timerManager.isPaused {
        Text(Utils.getExactTime(from: timerManager.adjustedStartDate))
          .font(.title)
      } else {
        Text(timerManager.adjustedStartDate, style: .relative)
          .font(.title)
      }
    }
  }
  
  private var controlButtonsView: some View {
    HStack(spacing: 20) {
      startPauseButton
      stopButton
    }
    .padding(.horizontal)
  }
  
  private var startPauseButton: some View {
    Group {
      if !timerManager.isTimerRunning {
        actionButton(title: "Start Timer", color: .green, action: startTimer)
      } else if timerManager.isPaused {
        actionButton(title: "Resume Timer", color: .blue) {
          timerManager.togglePause()
        }
      } else {
        actionButton(title: "Pause Timer", color: .yellow) {
          timerManager.togglePause()
        }
      }
    }
  }
  
  private var stopButton: some View {
    actionButton(title: "Stop Timer", color: .red, action: stopTimer)
      .disabled(!timerManager.isTimerRunning)
  }
  
  private func actionButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(title)
        .font(.headline)
        .padding()
        .frame(maxWidth: .infinity)
        .background(color)
        .foregroundColor(.white)
        .cornerRadius(10)
    }
  }
}

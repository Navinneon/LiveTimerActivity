//
//  TimerView.swift
//  LiveTimerActivity
//
//  Created by Navin Kumar on 01/12/24.
//

import SwiftUI

struct TimerView: View {
  @StateObject private var timerManager = TimerManager.shared
  
  var body: some View {
    VStack(spacing: 20) {
      headerView
      timerStatusView
      controlButtonsView
    }
    .padding()
  }
  
  private func startTimer() {
    timerManager.startTimerActivity(timerName: "Timer")
  }
  
  private func stopTimer() {
    Task {
      await timerManager.stopTimerActivity()
    }
  }
  
  private var headerView: some View {
    Text("Dynamic Island Timer")
      .font(.largeTitle)
      .bold()
  }
  
  private var timerStatusView: some View {
    Group {
      if !timerManager.isTimerRunning {
        Text(timerManager.getExactTime(from: Date()))
          .font(.title)
      } else if timerManager.isPaused {
        Text(timerManager.getExactTime(from: timerManager.adjustedStartDate))
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
        actionButton(title: "Resume Timer", color: .blue, action: timerManager.togglePause)
      } else {
        actionButton(title: "Pause Timer", color: .yellow, action: timerManager.togglePause)
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

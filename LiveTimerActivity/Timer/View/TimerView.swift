//
//  TimerView.swift
//  LiveTimerActivity
//
//  Created by Navin Kumar on 01/12/24.
//

import SwiftUI

struct TimerView: View {
  @Environment(\.scenePhase) var scenePhase
  @StateObject private var viewModel: TimerViewModel
      
  init(timerType: TimerType) {
    _viewModel = StateObject(wrappedValue: TimerViewModel(timerName: timerType.rawValue))
  }
  
  var body: some View {
    mainView
      .onChange(of: scenePhase) { oldPhase, newPhase in
        if newPhase == .active {
          Task {
            viewModel.loadExistingTimer()
          }
        }
      }
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
    viewModel.startTimerActivity()
  }
  
  private func stopTimer() {
    Task {
      await viewModel.stopTimerActivity()
    }
  }
  
  private var titleView: some View {
    Text(viewModel.timerName)
      .font(.title2)
      .bold()
  }
  
  private var timerStatusView: some View {
    Group {
      if !viewModel.isTimerRunning {
        // Show elapsed time from adjustedStartDate (not running)
        Text(Utils.getExactTime(from: viewModel.adjustedStartDate))
          .font(.title)
      } else if viewModel.isPaused {
        // Show elapsed time from adjustedStartDate to pauseDate
        if let pauseDate = viewModel.pauseDate {
          Text(Utils.getExactTime(from: viewModel.adjustedStartDate, to: pauseDate))
            .font(.title)
        } else {
          Text(Utils.getExactTime(from: viewModel.adjustedStartDate))
            .font(.title)
        }
      } else {
        // Show live updating relative time
        Text(viewModel.adjustedStartDate, style: .relative)
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
      if !viewModel.isTimerRunning {
        actionButton(title: "Start Timer", color: .green, action: startTimer)
      } else if viewModel.isPaused {
        actionButton(title: "Resume Timer", color: .blue) {
          viewModel.togglePause()
        }
      } else {
        actionButton(title: "Pause Timer", color: .yellow) {
          viewModel.togglePause()
        }
      }
    }
  }
  
  private var stopButton: some View {
    actionButton(title: "Stop Timer", color: .red, action: stopTimer)
      .disabled(!viewModel.isTimerRunning)
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

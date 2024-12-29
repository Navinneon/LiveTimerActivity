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
      Text("Dynamic Island Timer")
        .font(.largeTitle)
        .bold()
      
      Text("Elapsed Time: \(Int(timerManager.elapsedTime)) seconds")
        .font(.title)
      
      HStack(spacing: 20) {
        if !timerManager.isTimerRunning {
          Button(action: startTimer) {
            Text("Start Timer")
              .font(.headline)
              .padding()
              .frame(maxWidth: .infinity)
              .background(Color.green)
              .foregroundColor(.white)
              .cornerRadius(10)
          }
        } else if timerManager.isPaused {
          Button(action: timerManager.togglePause) {
            Text("Resume Timer")
              .font(.headline)
              .padding()
              .frame(maxWidth: .infinity)
              .background(Color.blue)
              .foregroundColor(.white)
              .cornerRadius(10)
          }
        } else {
          Button(action: timerManager.togglePause) {
            Text("Pause Timer")
              .font(.headline)
              .padding()
              .frame(maxWidth: .infinity)
              .background(Color.yellow)
              .foregroundColor(.white)
              .cornerRadius(10)
          }
        }
        
        Button(action: stopTimer) {
          Text("Stop Timer")
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(!timerManager.isTimerRunning)
      }
      .padding(.horizontal)
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
}

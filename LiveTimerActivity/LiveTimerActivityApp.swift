//
//  LiveTimerActivityApp.swift
//  LiveTimerActivity
//
//  Created by Navin Kumar on 30/11/24.
//

import SwiftUI

@main
struct LiveTimerActivityApp: App {
  var body: some Scene {
    WindowGroup {
      ScrollView {
        VStack(spacing: 20) {
          headerView
          timerView
        }
      }
    }
  }
  
  private var headerView: some View {
    Text("Live Activity")
      .font(.title)
      .bold()
  }
  
  private var timerView: some View {
    VStack(spacing: 20) {
      TimerView(timerType: .first)
      TimerView(timerType: .second)
      TimerView(timerType: .third)
    }
  }
}


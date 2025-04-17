# Live Timer Updates with Dynamic Island & Lock Screen

A fully functional iOS demo app that showcases how to implement **Live Activities** with real-time timer updates on both the **Lock Screen** and **Dynamic Island** using SwiftUI and ActivityKit.

<div align="center">
  <img src="https://github.com/user-attachments/assets/07272070-170d-42f6-96ca-f6e35319cd25" width="30%"/>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/e2aab5dc-a14f-4095-b734-eaf0cbf066c8" width="30%"/>
  <br/>
  <i>Live Activities in Dynamic Island (left) & Lock Screen (right)</i>
</div>

---

## 🧭 Implementation Roadmap

Here’s the structured approach we follow to implement **Live Timer Activities**:

### 1. Designing `TimerView` – Creating Three Timer Types  
Build a SwiftUI view to support First, Second, and Third timers using a modular design pattern.

### 2. Defining Activities and Attributes  
Define `ActivityAttributes` and `ContentState` using ActivityKit to manage and update Live Activity states.

### 3. Building the Dynamic Island View  
Customize the `DynamicIsland` layout for:
- Compact leading/trailing
- Minimal
- Expanded leading/trailing/bottom regions
- Lock screen banner

### 4. Setting Up the Core Data Model  
Use Core Data to persist timer data, allowing the app to track multiple timers simultaneously.

### 5. `TimerViewModel`: Managing Timer and Live Activity  
Create a SwiftUI view model to:
- Run timers
- Track their progress
- Trigger updates to Live Activities

### 6. Integrating `TimerViewModel` into `TimerView`  
Bind your timer logic with the UI to enable reactive updates for both the app and Live Activities.

### 7. Using App Intents for Live Activity Button Actions  
Allow users to interact with Live Activities (Pause, Stop, Restart) using Swift’s `AppIntents` framework.

### 8. 🎉 Final Outcome  
A polished app where timers are fully synced with the Lock Screen and Dynamic Island, supporting multiple concurrent live timers.

---

//
//  TimerDataManager.swift
//  LiveTimerActivity
//
//  Created by Navin Kumar on 09/02/25.
//


import CoreData

class TimerDataManager {
  static let shared = TimerDataManager()
  private let context: NSManagedObjectContext
  
  init() {
    let container = NSPersistentContainer(name: "TimerModel")
    container.loadPersistentStores { _, error in
      if let error = error {
        fatalError("Failed to load Core Data stack: \(error)")
      }
    }
    self.context = container.viewContext
  }
  
  /// Fetches an existing timer from Core Data.
  func fetchTimer(for name: String) -> TimerEntity? {
    let request: NSFetchRequest<TimerEntity> = TimerEntity.fetchRequest()
    request.predicate = NSPredicate(format: "timerName == %@", name)
    return try? context.fetch(request).first
  }
  
  /// Loads an existing timer or creates a new one if it doesn't exist.
  func loadOrCreateTimer(name: String) -> TimerEntity {
    if let existingTimer = fetchTimer(for: name) {
      return existingTimer
    } else {
      let newTimer = TimerEntity(context: context)
      newTimer.timerName = name
      newTimer.isPaused = false
      newTimer.adjustedStartDate = Date()
      saveContext()
      return newTimer
    }
  }
  
  func createOrUpdateTimer(name: String, isPaused: Bool, pauseDate: Date?, adjustedStartDate: Date, activityID: String?) {
    let timer = fetchTimer(for: name) ?? TimerEntity(context: context)
    timer.timerName = name
    timer.isPaused = isPaused
    timer.pauseDate = pauseDate
    timer.adjustedStartDate = adjustedStartDate
    timer.activityID = activityID
    saveContext()
  }
  
  /// Deletes a timer entry.
  func deleteTimer(name: String) {
    if let timer = fetchTimer(for: name) {
      context.delete(timer)
      saveContext()
    }
  }

  func saveContext() {
    do {
      try context.save()
    } catch {
      print("Failed to save Core Data: \(error)")
    }
  }
}

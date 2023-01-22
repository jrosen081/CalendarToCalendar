//
//  BackgroundSyncPerformer.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 12/10/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import EventKit
import Foundation
import BackgroundTasks

struct BackgroundSyncPerformer {
    enum Constants {
        static let identifier = "com.jrosen081.background_sync"
    }
    
    static func performTask(task: BGTask) {
        let asyncTask = Task.detached(priority: .background) {
            for server in CurrentServer.allCases.map(\.interactor) where server.isSignedIn {
                try? await server.signIn() // Try to sign in first
            }
            let allTasks = await BackgroundSyncSaver.getTasks()
            if Task.isCancelled {
                return
            }
            
            await withTaskGroup(of: Void.self) { group in
                for task in allTasks {
                    group.addTask {
                        do {
                            let eventStore = EKEventStore()
                            // If I can't use the event calendar, stop
                            guard EKEventStore.authorizationStatus(for: .event) == .authorized else { return }
                            // Sync the upcoming year
                            let yearInFuture = Foundation.Calendar.current
                                    .date(byAdding: .year, value: 1, to: Date())
                            let request = try await task.server
                                .interactor.fetchEvents(name: task.name,
                                                        startDate: Date(),
                                                        endDate: yearInFuture!,
                                                        calendarID: task.id)
                            let newEvents = request.map { event in
                                var newEvent = event
                                newEvent.name = task.name ?? event.name
                                newEvent.alarm = task.newAlarm
                                return newEvent
                            }
                            guard !Task.isCancelled else { return }
                            // Filter out events that have already been added
                            let filteredOutEvents = newEvents.filter { event in
                                let predicate = eventStore.predicateForEvents(withStart: event.startDate,
                                                                              end: event.endDate,
                                                                              calendars: nil)
                                let eventsInCalendar = eventStore.events(matching: predicate)
                                return eventsInCalendar.contains { calendarEvent in
                                    Event(ekEvent: calendarEvent, id: event.id) == event
                                }
                            }
                            
                            guard !Task.isCancelled else { return }
                            
                            let _ = await EventSaver.save(events: filteredOutEvents)
                        } catch {
                            print(error)
                        }
                    }
                }
                await group.waitForAll()
            }
            
            task.setTaskCompleted(success: true)
            submitRequest(fromFailure: false)
        }
        
        task.expirationHandler = {
            asyncTask.cancel()
            task.setTaskCompleted(success: false)
            submitRequest(fromFailure: true)
        }
    }
    
    static func submitRequest(fromFailure: Bool) {
        BGTaskScheduler.shared.cancelAllTaskRequests()
        let refreshRequest = BGAppRefreshTaskRequest(identifier: Constants.identifier)
        refreshRequest.earliestBeginDate = Date().addingTimeInterval(fromFailure ? 60 : 3600)
        do {
            try BGTaskScheduler.shared.submit(refreshRequest)
        } catch {
            print(error)
        }
        
    }
}

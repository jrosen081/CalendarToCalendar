//
//  EventSaver.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/14/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import Foundation
import EventKit

struct EventSaver {
    static func save(events: [Event]) async -> EventError? {
        let eventStore = EKEventStore()
        do {
            guard try await eventStore.requestAccess(to: .event) else { return .notAllowed }
        } catch {
            return .notAllowed
        }
        do {
            
            for event in events {
                try eventStore.save(event.createCalendarEvent(eventStore),
                                    span: .thisEvent)
            }
            return nil
        } catch {
            print(error)
            return .error
        }
    }
}

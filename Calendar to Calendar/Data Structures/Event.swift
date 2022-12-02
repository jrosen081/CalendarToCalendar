//
//  Event.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 4/9/18.
//  Copyright © 2018 Jack Rosen. All rights reserved.
//

import Foundation
import EventKit
import SwiftUI

enum AlarmSetting: Int, CaseIterable {
    case none
    case fiveBefore
    case fifteenBefore
    case thirtyBefore
    case oneHour
    case twoHours
    case sixHours
    case oneDay
    case twoDays
    case oneWeek
    
    var secondsBefore: Int {
        switch self{
        case .none: return 0
        case .fiveBefore: return -300
        case .fifteenBefore: return -900
        case .thirtyBefore: return -1800
        case .oneHour: return -3600
        case .twoHours: return -7200
        case .sixHours: return -21600
        case .oneDay: return -86400
        case .twoDays: return -172800
        case .oneWeek: return -604800
        }
    }
}

struct Event: Equatable, Identifiable {
    let id: String
    var name: String
    var startDate: Date
    var endDate: Date
    var alarm: AlarmSetting = .none
    var isAllDay: Bool
    public static let alarmPickerDate:[String] = ["No Alarm", "5 Minutes Before", "15 Minutes Before", "30 Minutes Before", "1 Hour Before", "2 Hours Before", "6 Hours Before", "1 Day Before", "2 Days Before", "1 Week Before"]
    
    func createCalendarEvent(_ store: EKEventStore) -> EKEvent {
        let event = EKEvent(eventStore: store)
        event.title = self.name
        event.isAllDay = self.isAllDay
        event.startDate = self.startDate
        event.endDate = isAllDay ? self.startDate : self.endDate
        if (alarm != .none){
            let alarm = EKAlarm(relativeOffset: TimeInterval(self.alarm.secondsBefore))
            event.addAlarm(alarm)
        }
        event.calendar = store.defaultCalendarForNewEvents
        return event
    }
}
extension Event {
    init(id: String, name: String, startDate: Date, endDate: Date, isAllDay: Bool) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
    }
}

//
//  Event.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 4/9/18.
//  Copyright © 2018 Jack Rosen. All rights reserved.
//

import Foundation

struct Event: Equatable{
    var name: String
    let startDate: Date
    let endDate: Date
    let formattedEndDate: String
    let formattedStartDate: String
    var alarm: Int
    let isAllDay: Bool
    private let alarmPickerDate:[String] = ["No Alarm", "5 Minutes Before", "15 Minutes Before", "30 Minutes Before", "1 Hour Before", "2 Hours Before", "6 Hours Before", "1 Day Before", "2 Days Before", "1 Week Before"]
    var description: String{
        var name = ""
        if (self.name != ""){
            name = "\"\(self.name)\""
        }else {
            name = "The event"
        }
        var alarmData = ""
        if (alarm == 0){
            alarmData = "No alarm will be set."
        }
        else{
            alarmData = "An alarm will be set \(alarmPickerDate[alarm])."
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dayOfWeek = getDayOfWeek(date: self.startDate)
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm a"
        let endDate = isAllDay ? " and is an all day event." : " and ends on \(getDayOfWeek(date: self.endDate)) at \(timeFormatter.string(from: self.endDate))."
        let startFormatted = "\(dayOfWeek), \(dateFormatter.string(from: self.startDate))\(isAllDay ? "" : " at \(timeFormatter.string(from: self.startDate))")"
        return "\(name) starts on \(startFormatted)\(endDate) \(alarmData)"
    }
    private func getDayOfWeek(date: Date) -> String
    {
        let calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let dayOfWeek = calendar.component(.weekday, from: date)
        return DateFormatter().weekdaySymbols[dayOfWeek - 1]
    }
    static func == (firstEvent: Event, event: Event) -> Bool{
        return firstEvent.name == event.name && firstEvent.startDate == event.startDate && firstEvent.endDate == event.endDate
    }
}
extension Event{
    init(name: String, startDate: Date, endDate: Date,  formattedEndDate: String, formattedStartDate: String, isAllDay: Bool){
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.formattedStartDate = formattedStartDate
        self.formattedEndDate = formattedEndDate
        self.isAllDay = isAllDay
        self.alarm = 0
    }
}

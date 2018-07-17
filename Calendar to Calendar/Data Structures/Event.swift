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
    static func == (firstEvent: Event, event: Event) -> Bool{
        return firstEvent.name == event.name && firstEvent.startDate == event.startDate && firstEvent.endDate == event.endDate
    }
}

//
//  Calendar.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 8/13/18.
//  Copyright © 2018 Jack Rosen. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST

struct Calendar: Hashable, Identifiable {
    let name: String
    let identifier: String
    
    var id: String { identifier }
}
extension Calendar{
    init(googleCalendar: GTLRCalendar_CalendarListEntry){
        self.name = googleCalendar.summary ?? ""
        self.identifier = googleCalendar.identifier ?? ""
    }
}

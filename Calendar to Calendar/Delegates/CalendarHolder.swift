//
//  CalendarHolder.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 4/30/19.
//  Copyright © 2019 Jack Rosen. All rights reserved.
//

import Foundation

protocol CalendarHolder {
	/// The calendars of the current calendar
	var calendars: [Calendar] {get}
	
	/// Adds a calendar to the list
	func addCalendar(calendar: Calendar)
	
	/// Removes all calendars
	func removeAll()
}

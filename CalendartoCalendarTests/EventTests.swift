//
//  EventTests.swift
//  CalendartoCalendarTests
//
//  Created by Jack Rosen on 1/22/23.
//  Copyright © 2023 Jack Rosen. All rights reserved.
//

import XCTest

final class EventTests: XCTestCase {

    func testEvents() {
        let event = Event(id: "",
                          name: "",
                          startDate: Date(),
                          endDate: Date(),
                          isAllDay: false)
        XCTAssertEqual(event.alarm, AlarmSetting.none)
    }

}

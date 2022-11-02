//
//  CalendarInteractor.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/1/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import Foundation
import UIKit

protocol CalendarInteractor {
    func signIn(controller: UIViewController) async throws
    func restoreSignIn() async throws
    func events(name: String?, startDate: Date, endDate: Date, calendarID: String) async -> [Event]
    func calendars() async -> [Calendar]
}

class MockCalendarInteractor: CalendarInteractor {
    func signIn(controller: UIViewController) async throws {
        
    }
    
    func restoreSignIn() async throws {
        
    }
    
    func events(name: String?, startDate: Date, endDate: Date, calendarID: String) async -> [Event] {
        return []
    }
    
    func calendars() async -> [Calendar] {
        return []
    }
    
    
}

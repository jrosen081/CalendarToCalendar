//
//  APIInteractor.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 8/14/18.
//  Copyright © 2018 Jack Rosen. All rights reserved.
//

import Foundation

protocol CalendarInteractor {
    func signIn() async throws
    func tryToSignInSilently()
    func signOut()
    func fetchEvents(name: String?, startDate: Date, endDate: Date, calendarID: String) async throws -> [Event]
    func getCalendars() async throws -> [Calendar]
    var isSignedIn: Bool { get }
}

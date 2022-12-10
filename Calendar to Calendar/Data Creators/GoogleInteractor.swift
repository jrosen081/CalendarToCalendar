//
//  GoogleInteractor.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 6/28/18.
//  Copyright © 2018 Jack Rosen. All rights reserved.
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST

class GoogleInteractor: NSObject, CalendarInteractor {

    var isSignedIn: Bool {
        return GIDSignIn.sharedInstance.hasPreviousSignIn() || GIDSignIn.sharedInstance.currentUser != nil
    }
    private let service = GTLRCalendarService()
    static let sharedInstance = GoogleInteractor()
    private let scopes = [kGTLRAuthScopeCalendarReadonly]

    private lazy var configuration = GIDConfiguration(clientID: "140821696802-p1vcstjg021t9v3b3n90nie63n01f6s6.apps.googleusercontent.com")

    private func signInCallbackCreator(continuation: CheckedContinuation<(), Error>?) -> GIDSignInCallback {
        return { user, error in
            if let error {
                continuation?.resume(throwing: error)
            } else if let user {
                if user.grantedScopes?.contains(where: self.scopes.contains(_:)) == true {
                    continuation?.resume()
                    self.service.authorizer = user.authentication.fetcherAuthorizer()
                } else {
                    GIDSignIn.sharedInstance.addScopes(self.scopes,
                                                       presenting: OutlookInteractor.viewController,
                                                       callback: self.signInCallbackCreator(continuation: continuation))
                }
            }
        }
    }

    func signIn() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async { [self] in
                let callback = signInCallbackCreator(continuation: continuation)
                if isSignedIn {
                    GIDSignIn.sharedInstance.restorePreviousSignIn(callback: callback)
                } else {
                    GIDSignIn.sharedInstance.signIn(with: configuration,
                                                    presenting: OutlookInteractor.viewController,
                                                    callback: callback
                    )
                }
            }
        }
    }

    func tryToSignInSilently() {
        if isSignedIn {
            GIDSignIn.sharedInstance.restorePreviousSignIn(callback: signInCallbackCreator(continuation: nil))
        }
    }

    func getCalendars() async throws -> [Calendar] {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[Calendar], Error>) -> Void in
            let query: GTLRCalendarQuery_CalendarListList = GTLRCalendarQuery_CalendarListList.query()
            query.showHidden = true
            query.showDeleted = true
            self.service.executeQuery(query) { _, response, error in
                if let response = response as? GTLRCalendar_CalendarList,
                    let calendars = response.items {
                    continuation.resume(returning: calendars
                        .map {calendar in Calendar(googleCalendar: calendar)})
                } else {
                    continuation.resume(throwing: error!)
                }
            }
        }
    }

    func fetchEvents(name: String?, startDate: Date, endDate: Date, calendarID: String) async throws -> [Event] {
        return try await withCheckedThrowingContinuation { continuation in
            let query = GTLRCalendarQuery_EventsList.query(withCalendarId: calendarID)
            query.timeMin = GTLRDateTime.init(date: startDate)
            query.timeMax = GTLRDateTime.init(date: endDate)
            query.orderBy = "startTime"
            query.singleEvents = true
            if let name = name {
                query.q = name
            }
            self.service.executeQuery(query) { _, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                var events = [Event]()
                if let response = response as? GTLRCalendar_Events,
                    let eventItems = response.items {
                    for event in eventItems {
                        let startDate: Date
                        let endDate: Date
                        let name = event.summary!
                        var isAllDay = true
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                        if let start = event.start!.dateTime {
                            startDate = dateFormatter.date(from: start.rfc3339String)!
                            endDate = dateFormatter.date(from: event.end!.dateTime!.rfc3339String)!
                            isAllDay = false
                        } else {
                            let start = event.start!.date!
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            startDate = dateFormatter.date(from: start.rfc3339String)!
                            endDate = dateFormatter.date(from: event.end!.date!.rfc3339String)!
                        }
                        events.append(Event(id: event.identifier ?? UUID().uuidString, name: name, startDate: startDate, endDate: endDate, isAllDay: isAllDay))
                    }
                    continuation.resume(returning: events)
                } else {
                    continuation.resume(throwing: NSError(domain: "", code: 1200))
                }
            }
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
}

//
//  APIInteractor.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 8/14/18.
//  Copyright © 2018 Jack Rosen. All rights reserved.
//

import Foundation

protocol APIInteractor: class {
    /** The delegate that the class sends data to */
    var delegate: InteractionDelegate? {get set}
    /** A boolean value of whether the user is signed in with the respective service */
    var isSignedIn: Bool {get}
    /**
     The function to sign in the user to either service.
     - parameter from: the object to display the OAuth instance from
     */
    func signIn(from: AnyObject)
    /**
     A method to sign out the user from the service.
     */
    func signOut()
    /**
     A function to get the events from the server.
     - parameters:
        - name: The name of the event or nil if the user wants all of the events
        - startDate: The earliest date of an event
        - endDate: The latest date of an event
        - calendarID: The ID of the calendar to look through
     */
    func fetchEvents(name: String?, startDate: Date, endDate: Date, calendarID: String)
    /**
     A method to get all calendars from the server
     */
    func getCalendars()
}

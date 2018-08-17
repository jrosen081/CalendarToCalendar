//
//  APIInteractor.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 8/14/18.
//  Copyright © 2018 Jack Rosen. All rights reserved.
//

import Foundation

protocol APIInteractor {
    var delegate: InteractionDelegate? {get set}
    var isSignedIn: Bool {get}
    func signIn(from: AnyObject)
    func signOut()
    func fetchEvents(name: String?, startDate: Date, endDate: Date, calendarID: String)
    func getCalendars()
}

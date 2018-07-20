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

class GoogleInteractor: NSObject, GIDSignInDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            delegate?.returnedError(error: CustomError(error.localizedDescription))
            self.service.authorizer = nil
        } else {
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            delegate?.returnedResults(data: user)
        }
    }
    var isSignedIn: Bool{
        return GIDSignIn.sharedInstance().hasAuthInKeychain()
    }
    var name: Name = .none
    private let service = GTLRCalendarService()
    static let sharedInstance = GoogleInteractor()
    private let scopes = [kGTLRAuthScopeCalendar]
    weak var delegate: GoogleInteractionDelegate?
    private override init(){
        super.init()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = scopes
    }
    func signOut(){
        GIDSignIn.sharedInstance().signOut()
    }
    //Gets Calendar Names
    func getCalendars(){
        DispatchQueue.global(qos: .utility).async{
            let query: GTLRCalendarQuery_CalendarListList = GTLRCalendarQuery_CalendarListList.query()
            query.showHidden = true
            query.showDeleted = true
            self.service.executeQuery(
                query,
                delegate: self,
                didFinish: #selector(self.returnCalendars(ticket:finishedWithObject:error:)))
        }
    }
    @objc
    func returnCalendars(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_CalendarList,
        error : NSError?) {
        
        if let error = error {
            delegate?.returnedError(error: CustomError(error.localizedDescription))
            return
        }
        if let calendars = response.items, !calendars.isEmpty {
            delegate?.returnedResults(data: calendars)
        } else {
            delegate?.returnedError(error: "You need a Google Calendar for this app to work")
        }
    }
    //Gets events using criteria
    func fetchEvents(name: String?, startDate: Date, endDate: Date, calendarID: String) {
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: calendarID)
        query.timeMin = GTLRDateTime.init(date: startDate)
        query.timeMax = GTLRDateTime.init(date: endDate)
        query.orderBy = "startTime"
        query.singleEvents = true
        if let name = name{
            query.q = name
            self.name = .name(name)
        }else{
            self.name = .none
        }
        service.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    // Formats the events
    @objc
    func displayResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Events,
        error : NSError?) {
        
        if let error = error {
            delegate?.returnedError(error: CustomError(error.localizedDescription))
            return
        }
        var events = [Event]()
        if let eventItems = response.items, !eventItems.isEmpty {
            for event in eventItems {
                if let start = event.start!.dateTime {
                    let end = event.end!.dateTime!
                    let dateFromStringFormatter = DateFormatter()
                    dateFromStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    let StringFromDateFormatter = DateFormatter()
                    StringFromDateFormatter.dateFormat = "mm/dd/yyy, HH:MM a"
                    let date = dateFromStringFormatter.date(from: start.rfc3339String)
                    let enddate = dateFromStringFormatter.date(from: end.rfc3339String)
                    let userVisibleDateFormatter = DateFormatter()
                    userVisibleDateFormatter.dateStyle = DateFormatter.Style.short
                    userVisibleDateFormatter.timeStyle = DateFormatter.Style.short
                    let userVisibleDateTimeString = userVisibleDateFormatter.string(from: date!)
                    let endDate = userVisibleDateFormatter.string(from: enddate!)
                    let event = Event(name: event.summary!, startDate: start.date, endDate: end.date, formattedEndDate: endDate, formattedStartDate: userVisibleDateTimeString, isAllDay: false)
                    events.append(event)
                }
                else
                {
                    let start = event.start!.date!
                    let dateFromStringFormatter = DateFormatter()
                    dateFromStringFormatter.dateFormat = "yyyy-MM-dd"
                    let StringFromDateFormatter = DateFormatter()
                    StringFromDateFormatter.dateFormat = "mm/dd/yyyy"
                    let date = dateFromStringFormatter.date(from: start.rfc3339String)
                    let userVisibleDateFormatter = DateFormatter()
                    let timeZone: Int = TimeZone.current.secondsFromGMT() / 3600
                    var timeZoneString: String = ""
                    if (timeZone > 0)
                    {
                        timeZoneString = "+" + String(describing: timeZone)
                    }
                    else
                    {
                        timeZoneString = String(describing: timeZone)
                    }
                    if (timeZone < 10 && timeZone > -10)
                    {
                        timeZoneString.insert("0", at: timeZoneString.index(after: timeZoneString.startIndex))
                    }
                    userVisibleDateFormatter.dateStyle = DateFormatter.Style.short
                    userVisibleDateFormatter.timeStyle = DateFormatter.Style.short
                    let userVisibleDateTimeString = userVisibleDateFormatter.string(from: date!)
                    let event = Event(name: event.summary!, startDate: start.date, endDate: start.date, formattedEndDate: userVisibleDateTimeString, formattedStartDate: userVisibleDateTimeString, isAllDay: true)
                    events.append(event)
                }
            }
            self.delegate?.returnedResults(data: events)
        } else {
            var response = "There were no events"
            if case let .name(name) = self.name{
                response += " titled \(name)"
            }
            response += " during the time period."
            delegate?.returnedError(error: CustomError(response))
        }
        
    }
}

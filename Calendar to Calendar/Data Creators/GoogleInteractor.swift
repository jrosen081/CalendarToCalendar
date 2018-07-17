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
            errorDelegate?(CustomError(error.localizedDescription))
            self.service.authorizer = nil
        } else {
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            finishingClosure?(user)
        }
    }
    typealias Closure = (Any) -> ()
    typealias ErrorResponse = (CustomError) -> ()
    var isSignedIn: Bool{
        return GIDSignIn.sharedInstance().hasAuthInKeychain()
    }
    var errorDelegate: ErrorResponse?
    var finishingClosure: Closure?
    var hasName = false
    private let service = GTLRCalendarService()
    static let sharedInstance = GoogleInteractor()
    weak var signInUIDelegate: GIDSignInUIDelegate?{
        didSet{
            GIDSignIn.sharedInstance().uiDelegate = signInUIDelegate
        }
    }
    private let scopes = [kGTLRAuthScopeCalendar]
    private override init(){
        super.init()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = signInUIDelegate
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
            errorDelegate?(CustomError(error.localizedDescription))
            return
        }
        if let calendars = response.items, !calendars.isEmpty {
            finishingClosure?(calendars)
        } else {
            errorDelegate?(CustomError("You need a Google Calendar for this app to work"))
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
        }
        hasName = name != nil
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
            errorDelegate?(CustomError(error.localizedDescription))
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
                    let event = Event(name: event.summary!, startDate: start.date, endDate: end.date, formattedEndDate: endDate, formattedStartDate: userVisibleDateTimeString, alarm: 0, isAllDay: false)
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
                    let event = Event(name: event.summary!, startDate: start.date, endDate: start.date, formattedEndDate: userVisibleDateTimeString, formattedStartDate: userVisibleDateTimeString, alarm: 0, isAllDay: true)
                    events.append(event)
                }
            }
            finishingClosure?(events)
        } else {
            var response = "There were no events"
            if hasName{
                response += " titled that"
            }
            response += " during the time period."
            errorDelegate?(CustomError(response))
        }
        
    }
}

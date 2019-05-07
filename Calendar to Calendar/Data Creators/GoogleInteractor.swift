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

class GoogleInteractor: NSObject, GIDSignInDelegate, APIInteractor{
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            delegate?.returnedError(error: CustomError(error.localizedDescription))
        } else {
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            delegate?.returnedResults(data: user!)
        }
    }
    var isSignedIn: Bool{
        return GIDSignIn.sharedInstance().hasAuthInKeychain()
    }
    weak var uiDelegate: GIDSignInUIDelegate?{
        didSet{
            GIDSignIn.sharedInstance().uiDelegate = uiDelegate
        }
    }
    private var name: Name = .none
    private let service = GTLRCalendarService()
    static let sharedInstance = GoogleInteractor()
    private let scopes = [kGTLRAuthScopeCalendar]
	private let calendarHolder: CalendarHolder?
    weak var delegate: InteractionDelegate?
    override init(){
		self.calendarHolder = nil
        super.init()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = scopes
    }

	init(holder: CalendarHolder?) {
		self.calendarHolder = holder
		super.init()
		GIDSignIn.sharedInstance().delegate = self
		GIDSignIn.sharedInstance().scopes = scopes
	}
    
    func signIn(from object: AnyObject = GoogleInteractor.sharedInstance){
        if isSignedIn {
            GIDSignIn.sharedInstance().signInSilently()
        } else {
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    func signOut(){
        GIDSignIn.sharedInstance().signOut()
        calendarHolder?.removeAll()
    }
    //Gets Calendar Names
    func getCalendars(){
		if !(self.calendarHolder?.calendars.isEmpty ?? true) {
			return
		}
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
            calendars.forEach({calendar in self.calendarHolder?.addCalendar(calendar: Calendar(googleCalendar: calendar))})
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
                }
                else
                {
                    let start = event.start!.date!
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    startDate = dateFormatter.date(from: start.rfc3339String)!
                    endDate = dateFormatter.date(from: event.end!.date!.rfc3339String)!
                }
                events.append(Event(name: name, startDate: startDate, endDate: endDate, isAllDay: isAllDay))
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

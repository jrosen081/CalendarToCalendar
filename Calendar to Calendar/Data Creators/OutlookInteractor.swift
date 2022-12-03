//
//  OutlookInteractor.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 8/14/18.
//  Copyright © 2018 Jack Rosen. All rights reserved.
//

import Foundation
import p2_OAuth2
import SwiftyJSON

class OutlookInteractor: NSObject, CalendarInteractor {
    
    // Configure the OAuth2 framework for Azure
    private static let oauth2Settings = [
        "client_id" : "069f519d-d63c-49c0-a693-3ca17b2ea1d2",
        "authorize_uri": "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
        "token_uri": "https://login.microsoftonline.com/common/oauth2/v2.0/token",
        "scope": "openid profile offline_access User.Read Calendars.Read",
        "redirect_uris": ["CalendarToCalendar://oauth2/callback"],
        "verbose": true,
        ] as OAuth2JSON
    
    private let oauth2: OAuth2CodeGrant
    static let shared = OutlookInteractor()
    
    override init() {
        oauth2 = OAuth2CodeGrant(settings: OutlookInteractor.oauth2Settings)
        oauth2.authConfig.authorizeEmbedded = true
        oauth2.authConfig.authorizeEmbeddedAutoDismiss = true
        super.init()
        (UIApplication.shared.delegate as? AppDelegate)?.service = self
    }
    
    var isSignedIn: Bool {
        get {
            return oauth2.hasUnexpiredAccessToken() || oauth2.refreshToken != nil
        }
    }
    
    public static var viewController: UIViewController {
        var rootController = UIApplication.shared.windows.first?.rootViewController ?? UIViewController()
        while let presented = rootController.presentedViewController {
            rootController = presented
        }
        return rootController
    }
    
    @MainActor
    func signIn() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            oauth2.authorizeEmbedded(from: Self.viewController) { result, error in
                if let unwrappedError = error {
                    self.signOut()
                    continuation.resume(with: .failure(unwrappedError))
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func tryToSignInSilently() {
        if isSignedIn {
            oauth2.tryToObtainAccessTokenIfNeeded(callback: {_, _ in })
        }
    }
    
    func fetchEvents(name: String?, startDate: Date, endDate: Date, calendarID: String) async throws -> [Event] {
        return try await withCheckedThrowingContinuation { continuation in
            let toDateFormatter = DateFormatter()
            toDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssssss"
            //Parameters for the query
            var params = [
                "$select": "subject,start,end,isAllDay",
                "$orderby": "start/dateTime ASC",
                "$filter": "start/dateTime ge '\(toDateFormatter.string(from: startDate))' and end/dateTime le '\(toDateFormatter.string(from: endDate))'"
            ]
            //If there is a name to check, add it to the filter and response text
            if let name = name{
                params["$filter"] = "\(params["$filter"]!) and contains(subject, '\(name)')"
            }
            //Makes the call to the outlook api
            makeApiCall(api: "/v1.0/me/calendars/\(calendarID)/events", params: params) {
                result in
                if let unwrappedResult = result as? OAuth2JSON{
                    var events = [Event]()
                    for (event) in JSON(unwrappedResult)["value"].arrayValue{
                        //Gets all of the values to create an event
                        let startString = event["start"].dictionaryValue["dateTime"]?.stringValue
                        let endString = event["end"].dictionaryValue["dateTime"]?.stringValue
                        let newName = event["subject"].stringValue
                        let isAllDay = event["isAllDay"].boolValue
                        guard startString != nil, endString != nil, let start = toDateFormatter.date(from: startString!), let end = toDateFormatter.date(from: endString!) else {
                            continuation.resume(throwing: NSError(domain: "com.jackrosen", code: 100))
                            return
                        }
                        events.append(Event(id: UUID().uuidString, name: newName, startDate: start, endDate: end, isAllDay: isAllDay))
                    }
                    continuation.resume(returning: events)
                } else if let error = result as? Error{
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getCalendars() async throws -> [Calendar] {
        return try await withCheckedThrowingContinuation { continuation in
            let params = ["$select": "id,name"]
            //Makes the api call to get all of the calendars
            makeApiCall(api: "/v1.0/me/calendars", params: params) {
                result in
                if let unwrappedResult = result as? OAuth2JSON{
                    var calendars = [Calendar]()
                    for (calendar) in JSON(unwrappedResult)["value"].arrayValue{
                        calendars.append(Calendar(name: calendar["name"].stringValue, identifier: calendar["id"].stringValue))
                    }
                    continuation.resume(returning: calendars)
                } else if let error = result as? Error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func handleOAuthCallback(url: URL) -> Void {
        oauth2.handleRedirectURL(url)
    }
    
    private func makeApiCall(api: String, params: [String: String]? = nil, callback: @escaping (Any?) -> Void) {
        // Build the request URL
        var urlBuilder = URLComponents(string: "https://graph.microsoft.com")!
        urlBuilder.path = api
        
        if let unwrappedParams = params {
            // Add query parameters to URL
            urlBuilder.queryItems = [URLQueryItem]()
            for (paramName, paramValue) in unwrappedParams {
                urlBuilder.queryItems?.append(
                    URLQueryItem(name: paramName, value: paramValue))
            }
        }
        
        let apiUrl = urlBuilder.url!
        
        var req = oauth2.request(forURL: apiUrl)
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let loader = OAuth2DataLoader(oauth2: oauth2)
        
        // Uncomment this line to get verbose request/response info in
        // Xcode output window
        //loader.logger = OAuth2DebugLogger(.trace)
        
        loader.perform(request: req) {
            response in
            do {
                let dict = try response.responseJSON()
                DispatchQueue.main.async {
                    callback(dict)
                }
            }
            catch let error {
                DispatchQueue.main.async {
                    callback(error)
                }
            }
        }
    }
    
    func signOut() {
        oauth2.forgetTokens()
    }
}

//
//  ViewController2.swift
//  QuickstartApp
//
//  Created by Jack Rosen on 1/12/18.
//  Copyright © 2018 Jack Rosen. All rights reserved.
//
import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class ChooseExport: UIViewController,  GIDSignInDelegate, GIDSignInUIDelegate{
    //Global variables
    private let scopes = [kGTLRAuthScopeCalendar]
    private let service = GTLRCalendarService()
    private var calendars: [GTLRCalendar_CalendarListEntry] = [GTLRCalendar_CalendarListEntry]()
    private var pickerData:[String] = [String]()
    @IBOutlet weak var calendarLoad: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        calendarLoad.transform = transform
        calendarLoad.isHidden = true
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = self.scopes
        GIDSignIn.sharedInstance().signInSilently()
        getCalendars()
    }
    //Sign in to google
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.service.authorizer = user.authentication.fetcherAuthorizer()
        }
    }
    //Sends to next file
    @IBAction func partCal(_ sender: Any) {
        while (calendars.count == 0)
        {
            calendarLoad.isHidden = false
            getCalendars()
        }
        performSegue(withIdentifier: "partCalDet", sender: nil)
    }
    @IBAction func fullCal(_ sender: Any) {
        while (calendars.count == 0)
        {
            calendarLoad.isHidden = false
            getCalendars()
        }
        performSegue(withIdentifier: "FullCalendarSegue", sender: nil)
    }
    
    
    //Gets Calendar Names
    func getCalendars(){
        let query: GTLRCalendarQuery_CalendarListList = GTLRCalendarQuery_CalendarListList.query()
        query.showHidden = true
        query.showDeleted = true
        service.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(returnCalendars(ticket:finishedWithObject:error:)))
    }
    @objc
    func returnCalendars(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_CalendarList,
        error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        if let calendars = response.items, !calendars.isEmpty {
            self.calendars = calendars
            for calendar in calendars {
                pickerData.append(calendar.summary!)
            }
        } else {
        }
    }
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        DispatchQueue.main.async(execute: {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        })
    }
    //Sends the calendars to the next file
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? PartialView {
            viewControllerB.pickerData = self.pickerData
            viewControllerB.calendars = self.calendars
        }else if let viewControllerB = segue.destination as? fullView {
            viewControllerB.pickerData = self.pickerData
            viewControllerB.calendars = self.calendars
        }
    }
}


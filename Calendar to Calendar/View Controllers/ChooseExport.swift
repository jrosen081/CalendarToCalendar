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
import UserNotifications

class ChooseExport: UIViewController{
    //Global variables
    private let scopes = [kGTLRAuthScopeCalendar]
    private let service = GTLRCalendarService()
    var calendars: [GTLRCalendar_CalendarListEntry] = [GTLRCalendar_CalendarListEntry]()
    let googleUser = GoogleInteractor.sharedInstance
    private var finished = false
    private var change = ""
    var pickerData:[String] = [String]()
    @IBOutlet weak var calendarLoad: UIActivityIndicatorView!
    private var backgroundView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        calendarLoad.transform = transform
        calendarLoad.isHidden = true
        backgroundView.frame = calendarLoad.frame
        backgroundView.center = self.view.center
        backgroundView.transform = CGAffineTransform(scaleX: 2, y: 2)
        backgroundView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.3)
        backgroundView.isHidden = true
        self.view.addSubview(backgroundView)
        createNotification()
        googleUser.delegate = self
    }
    private func createNotification(){
        let content = UNMutableNotificationContent()
        content.title = "Your Calendar needs updating."
        content.body = "Come back to Calendar to Calendar to update your iPhone calendar with Google events."
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let dateComponents = DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: TimeZone.current, day: 1)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest.init(identifier: NotificationTitle.identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
            if let error = error{
                print(error.localizedDescription)
            }
        })
    }
    //Sends to next file
    @IBAction func partCal(_ sender: Any) {
        googleUser.getCalendars()
        self.calendarLoad.startAnimating()
        UIView.animate(withDuration: 0.3, animations: {
            self.calendarLoad.isHidden = false
            self.backgroundView.isHidden = false
        })
        self.change = "partCalDet"
    }
    @IBAction func fullCal(_ sender: Any) {
        googleUser.getCalendars()
        self.calendarLoad.startAnimating()
        UIView.animate(withDuration: 0.3, animations: {
            self.calendarLoad.isHidden = false
            self.backgroundView.isHidden = false
        })
        self.change = "FullCalendarSegue"
    }
    func changeLocation(_ location: String)
    {
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: self.change, sender: nil)
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
extension ChooseExport: GoogleInteractionDelegate{
    func returnedError(error: CustomError) {
        self.showAlert(title: "Error", message: error.localizedDescription)
    }
    func returnedResults(data: Any) {
        if let responses = data as? [GTLRCalendar_CalendarListEntry]{
            self.calendars = responses
            responses.forEach({calendar in
                if let _ = calendar.summary{
                    self.pickerData.append(calendar.summary!)
                }else{
                    self.calendars.remove(at: self.calendars.index(of: calendar)!)
                }
            })
        }
        self.changeLocation(self.change)
    }
}


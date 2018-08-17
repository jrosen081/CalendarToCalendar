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
import Foundation

class ChooseExport: UIViewController{
    
    //Global variables
    var serverUser = ServerInteractor.current
    private var finished = false
    private var change = ""
    var pickerData:[String] = [String]()
    @IBOutlet weak var calendarLoad: UIActivityIndicatorView!
    private var backgroundView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        AdInteractor.currentViewController = self
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
        serverUser.delegate = self
    }
    private func createNotification(){
        let content = UNMutableNotificationContent()
        content.title = "Your Calendar needs updating."
        content.body = "Come back to Calendar to Calendar to update your iPhone calendar with Google events."
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let dateComponents = DateComponents(calendar: Foundation.Calendar.autoupdatingCurrent, timeZone: TimeZone.current, day: 1)
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
        self.change = "partCalDet"
        if Calendars.all.isEmpty{
            serverUser.getCalendars()
            self.calendarLoad.startAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                self.calendarLoad.isHidden = false
                self.backgroundView.isHidden = false
            })
        } else {
            changeLocation(change)
        }
    }
    @IBAction func fullCal(_ sender: Any) {
        self.change = "FullCalendarSegue"
        if Calendars.all.isEmpty{
            serverUser.getCalendars()
            self.calendarLoad.startAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                self.calendarLoad.isHidden = false
                self.backgroundView.isHidden = false
            })
        } else {
            changeLocation(change)
        }
    }
    func changeLocation(_ location: String)
    {
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: self.change, sender: nil)
        })
    }
    
}
extension ChooseExport: InteractionDelegate{
    func returnedError(error: CustomError) {
        self.showAlert(title: "Error", message: error.localizedDescription)
    }
    func returnedResults(data: Any) {
        self.changeLocation(self.change)
    }
}


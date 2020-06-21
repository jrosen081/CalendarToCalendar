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
	var serverUser: APIInteractor?
    private var finished = false
	private var change: (() -> UIViewController?)? = nil
    var pickerData:[String] = [String]()
    @IBOutlet weak var calendarLoad: UIActivityIndicatorView!
    private var backgroundView = UIView()
	private var this = UIView.self
	var holder: HoldingController?
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
        serverUser?.delegate = self
		serverUser?.getCalendars()
    }
    private func createNotification(){
        let content = UNMutableNotificationContent()
        content.title = "Your Calendar needs updating."
        content.body = "Come back to Calendar to Calendar to update your iPhone calendar with Google events."
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let dateComponents = DateComponents(calendar: Foundation.Calendar.autoupdatingCurrent, timeZone: TimeZone.current, day: 1, hour: 9)
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
        self.change = { () in
			let vc = self.storyboard?.instantiateViewController(withIdentifier: "partCalendar") as? PartialView
			vc?.holder = self.holder
			return vc
		}
        changeCalendars()
    }
    @IBAction func fullCal(_ sender: Any) {
		self.change = { () in
			let vc = self.storyboard?.instantiateViewController(withIdentifier: "fullCalendar") as? fullView
			vc?.holding = self.holder
			return vc
		}
		changeCalendars()
    }
	private func changeCalendars(){
		if self.holder?.calendarHolder.calendars.isEmpty ?? false{
			serverUser?.getCalendars()
			self.calendarLoad.startAnimating()
			UIView.animate(withDuration: 0.3, animations: {
				self.calendarLoad.isHidden = false
				self.backgroundView.isHidden = false
			})
		} else {
			changeLocation(change)
		}
	}
	func changeLocation(_ location: (() -> UIViewController?)?)
    {
        DispatchQueue.main.async(execute: {
			if let vc = location?() {
				self.holder?.transition(from: self, to: vc, with: .rightToLeft)
			}
        })
    }
    
}
extension ChooseExport: InteractionDelegate{
    func returnedError(error: CustomError) {
        self.showAlert(title: "Error", message: error.localizedDescription)
    }
    func returnedResults(data: Any) {
		self.changeLocation(change)
    }
}


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
    deinit{
        googleUser.finishingClosure = nil
        googleUser.errorDelegate = nil
    }
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
        googleUser.errorDelegate = {error in
            self.showAlert(title: "Error", message: error.localizedDescription)
        }
        googleUser.finishingClosure = {calendars in
            if let responses = calendars as? [GTLRCalendar_CalendarListEntry]{
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


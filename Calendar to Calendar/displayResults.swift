//
//  displayResults.swift
//  QuickstartApp
//
//  Created by Jack Rosen on 1/18/18.
//  Copyright © 2018 Jack Rosen. All rights reserved.
//

import UIKit
import EventKit
import GoogleMobileAds

class customcell: UITableViewCell{
    @IBOutlet weak var nameOfEvent: UITextView!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var alarmPicker: UIPickerView!
    @IBOutlet weak var topBorder: UIView!
    @IBOutlet weak var bottomBorder: UILabel!
    
}
class displayResults: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, GADInterstitialDelegate{
    
    //Calls all of the variables
    private var alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
    private let alarmPickerDate:[String] = ["No Alarm", "5 Minutes Before", "15 Minutes Before", "30 Minutes Before", "1 Hour Before", "2 Hours Before", "6 Hours Before", "1 Day Before", "2 Days Before", "1 Week Before"]
    @IBOutlet weak var tableView: UITableView!
    private let store = EKEventStore()
    var events: [[String]] = [[String]]()
    private var eventsFinalized: [[String]] = [[String]]()
    let advertisement = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
    override func viewDidLoad() {
        //Adds a way to get rid of keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PartialView.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        //Loads the advertisement
        let request: GADRequest = GADRequest()
        request.testDevices = [kGADSimulatorID]
        advertisement.load(request)
        advertisement.delegate = self
        super.viewDidLoad()
        //Displays the table view
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 200
        //Gives starting instructions
        self.showAlert(title: "Hint:", message: "Click on the name of the event to change it.")
    }
    //When it stops editing, puts information into events
    func textViewDidEndEditing(_ textView: UITextView)
    {
        events[Int(textView.restorationIdentifier!)!][2] = textView.text
        tableView.tableFooterView = UIView()
        let indexPath = IndexPath(row: Int(textView.restorationIdentifier!)!, section: 0)
        UIView.animate(withDuration: 0.6, animations: {
            [weak self] in
            if (indexPath.row == (self?.events.count)! - 1)
        {
            self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
        else if (indexPath.row == 0){}
        else{
                self?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
            }}, completion: nil)
        tableView.isScrollEnabled = true
    }
    //Gets rid of keyboard on enter
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    //Moves text so it is visible
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        let rect = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height)
        tableView.tableFooterView = UIView(frame: rect)
        let indexPath = IndexPath(row: Int(textView.restorationIdentifier!)!, section: 0)
        UIView.animate(withDuration: 0.6, animations: {
            [weak self] in
            self?.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }, completion: nil)
        tableView.isScrollEnabled = false
    }
    //Picker View functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return alarmPickerDate.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return alarmPickerDate[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if let identifier = pickerView.restorationIdentifier
        {
            events[Int(identifier)!][5] = String(describing: row)
        }
    }
    //Changes the Alarm for each event
    @IBAction func fullAlarmChange(_ sender: Any) {
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: "How long before would you want an alarm for?", message: "This is for all events.", preferredStyle: .alert)
            let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 300)
            alert.view.addConstraint(height);
            let pickerFrame: CGRect = CGRect(x: 0, y: 100, width: 270, height: 100);
            let picker: UIPickerView = UIPickerView(frame: pickerFrame);
            picker.delegate = self
            picker.dataSource = self
            alert.view.addSubview(picker)
            let action1 = UIAlertAction(title: "Select", style: .default, handler: { (action) -> Void in
                let checker = picker.selectedRow(inComponent: 0)
                for counter in 0 ... self.events.count - 1
                {
                    if (self.events[counter].count != 6)
                    {
                        self.events[counter].append(String(describing: checker))
                    }
                    else{
                        self.events[counter][5] = String(describing: checker)
                    }
                }
                for cell in self.tableView.visibleCells as! Array<customcell>
                {
                    cell.alarmPicker.selectRow(checker, inComponent: 0, animated: true)
                }
            })
            let action2 = UIAlertAction(title: "Cancel", style: .default, handler: {(action) -> Void in})
            alert.addAction(action2)
            alert.addAction(action1)
            self.present(alert, animated: true, completion: nil)
        })
    }
    //Changes the name of all events
    @IBAction func changeAll(_ sender: Any) {
        DispatchQueue.main.async(execute: {
            self.alert = UIAlertController(title: "What would you like the name to be?", message: "", preferredStyle: .alert)
            self.alert.addTextField { (textField: UITextField) in
                textField.keyboardAppearance = .light
                textField.keyboardType = .default
                textField.placeholder = "Event Name"
                textField.textColor = UIColor.black
                textField.autocapitalizationType = UITextAutocapitalizationType.sentences
            }
            let action1 = UIAlertAction(title: "Rename", style: .default, handler: { (action) -> Void in
                for counter in 0 ... self.events.count - 1
                {
                    self.events[counter][2] = self.alert.textFields![0].text!
                }
                for cell in self.tableView.visibleCells as! Array<customcell>
                {
                    cell.nameOfEvent.text = self.alert.textFields![0].text!
                }
            })
            let action2 = UIAlertAction(title: "Cancel", style: .default, handler: {(action) -> Void in})
            self.alert.addAction(action2)
            self.alert.addAction(action1)
            self.present(self.alert, animated: true, completion: nil)
        })
    }
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    //Cell was selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: customcell = tableView.cellForRow(at: indexPath) as! customcell
        tableView.deselectRow(at: indexPath, animated: false)
        var name = cell.nameOfEvent.text!
        if (name != "")
        {
            name = "\"\(name)\" "
        }else {name = "The event "}
        var alarmData = ""
        if (cell.alarmPicker.selectedRow(inComponent: 0) == 0)
        {
            alarmData = "no alarm will be set."
        }
        else
        {
            alarmData = "an alarm will be set \(alarmPickerDate[cell.alarmPicker.selectedRow(inComponent: 0)])."
        }
        if (cell.endDate.text == "All Day")
        {
            let startDate = cell.startDate.text!
            let startDateParts: [String] = startDate.components(separatedBy: ", ")
            let dayOfWeek = getDayOfWeek(date: startDateParts[0])
            
            let startFormatted = "\(dayOfWeek), \(startDateParts[0])"
            showAlert(title: "Your Event", message: "\(name)starts on \(startFormatted) and is an all day event, and \(alarmData)")
        }
        else{
            let index1 = cell.startDate.text!.index(cell.startDate.text!.startIndex, offsetBy: 7)
            let startDateSuffix = cell.startDate.text![index1...]
            let startDate = String(startDateSuffix)
            let startDateParts: [String] = startDate.components(separatedBy: ", ")
            let dayOfWeek = getDayOfWeek(date: startDateParts[0])
            let startFormatted = "\(dayOfWeek), \(startDateParts[0]) at \(startDateParts[1])"
            let index2 = cell.endDate.text!.index(cell.endDate.text!.startIndex, offsetBy: 5)
            let endDateSuffix = cell.endDate.text![index2...]
            let endDate = String(endDateSuffix)
            let endDateParts: [String] = endDate.components(separatedBy: ", ")
            if (endDateParts[0] != startDateParts[0])
            {
                let dayOfEndDay = getDayOfWeek(date: endDateParts[0])
                let endFormatted = "\(dayOfEndDay), \(endDateParts[0]) at \(endDateParts[1])"
                showAlert(title: "Your Event", message: "\(name)starts on \(startFormatted) and ends on \(endFormatted), and \(alarmData)")
            }
            else
            {
                let endFormatted = "at \(endDateParts[1])"
                showAlert(title: "Your Event", message: "\(name)starts on \(startFormatted) and ends \(endFormatted), and \(alarmData)")
            }
        }
    }
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell") as! customcell
        var event = events[indexPath.row]
        cell.contentView.backgroundColor = UIColor.white
        cell.sizeToFit()
        cell.nameOfEvent.delegate = self
        cell.nameOfEvent.text = event[2]
        cell.nameOfEvent.allowsEditingTextAttributes = true
        if (event == events[0])
        {
            cell.topBorder.isHidden = false
        }else
        {
            cell.topBorder.isHidden = true
        }
        if (event[4] == "All Day")
        {
            cell.startDate.text = event[3]
            cell.endDate.text = event[4]
        }
        else
        {
            cell.startDate.text = "Start: \(event[3])"
            cell.endDate.text = "End: \(event[4])"
        }
        cell.alarmPicker.dataSource = self
        cell.alarmPicker.delegate = self
        cell.alarmPicker.reloadAllComponents()
        if (event.count != 6)
        {
            event.append("0")
        }
        cell.alarmPicker.selectRow(Int(event[5])!, inComponent: 0, animated: false)
        cell.alarmPicker.restorationIdentifier = String(describing: indexPath.row)
        cell.nameOfEvent.restorationIdentifier = String(describing: indexPath.row)
        events[indexPath.row] = event
        return cell
    }
    //Method to Remove an Event
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            events.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            if (events.count == 0)
            {
                DispatchQueue.main.async(execute: {
                    self.alert = UIAlertController(title: "You have no event chosen.", message: "", preferredStyle: .alert)
                    let action1 = UIAlertAction(title: "Go Back", style: .default, handler: { (action) -> Void in
                        self.performSegue(withIdentifier: "finish", sender: nil)
                    })
                    self.alert.addAction(action1)
                    self.present(self.alert, animated: true, completion: nil)
                })
                
            }else {
                for cell in tableView.visibleCells as! Array<customcell>
                {
                    let indexPath: IndexPath = tableView.indexPath(for: cell)!
                    cell.alarmPicker.restorationIdentifier = String(describing: indexPath.row)
                    cell.nameOfEvent.restorationIdentifier = String(describing: indexPath.row)
                    if indexPath.row == 0
                    {
                        cell.topBorder.isHidden = false
                    }
                }
            }
        }
    }
    func getDayOfWeek(date: String) -> String
    {
        let calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateDate = dateFormatter.date(from: date)!
        let dayOfWeek = calendar.component(.weekday, from: dateDate)
        return dateFormatter.weekdaySymbols[dayOfWeek - 1]
    }
    //Displays advertisement
    @IBAction func addEvents(_ sender: Any) {
        DispatchQueue.main.async(execute: {
            if self.advertisement.isReady {
                self.advertisement.present(fromRootViewController: self)
            }else{
                debugPrint("SIKE")
            }
        })
    }
    //Formats events to prepare for putting it into calendar
    func formatEvents()
    {
        var counter = 0
        for event in events
        {
            var alarm: Int = 0
            if (event.count == 6)
            {
            if (event[5] == "0"){}
                else if (event[5] == "4")
                {
                    alarm = -3600
                }
                else if (event[5] == "5")
                {
                    alarm = -7200
                }
                else if (event[5] == "6")
                {
                    alarm = -21600
                }
                else if (event[5] == "7")
                {
                    alarm = -86400
                }
                else if (event[5] == "1")
                {
                    alarm = -300
                }
                else if (event[5] == "2")
                {
                    alarm = -900
                }
                else if (event[5] == "3")
                {
                    alarm = -1800
                }
                else if (event[5] == "8")
                {
                    alarm = -172800
                }
                else if (event[5] == "9")
                {
                    alarm = -604800
                }
            }
            let event1: [String] = [events[counter][0], events[counter][1], events[counter][4], events[counter][2], String(alarm)]
            eventsFinalized.append(event1)
            counter = counter + 1
        }
        addEventToCalendar(events: eventsFinalized)
    }
    //Adds events to calendar
    func addEventToCalendar(events: [[String]]) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let dateForCal: Date = dateFormatter.date(from: events[0][0])!
        let interval: TimeInterval = dateForCal.timeIntervalSinceReferenceDate
        store.requestAccess(to: .event) { (success, error) in
            if  error == nil {
                for event1 in events {
                    let event = EKEvent(eventStore: self.store)
                    event.title = event1[3]
                    
                    event.calendar = self.store.defaultCalendarForNewEvents// this will return deafult calendar from device calendars
                    event.startDate = dateFormatter.date(from: event1[0])!
                    if (event1[2] == "All Day")
                    {
                        event.isAllDay = true;
                        event.endDate = event.startDate
                    }
                    else{
                        event.endDate = dateFormatter.date(from: event1[1])!
                    }
                    if (event1[4] != "0")
                    {
                        let date: Date = Date.init(timeInterval: Double(event1[4])!, since: dateFormatter.date(from: event1[0])!)
                        let alarm = EKAlarm.init(absoluteDate: date)
                        event.addAlarm(alarm)
                    }
                    do {
                        try self.store.save(event, span: .thisEvent)
                        //event created successfullt to default calendar
                    } catch let error as NSError {
                        self.showAlert(title: "", message: "Failed to save event with error : \(error)")
                    }
                }
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertController(title: "Events Were Created", message: "", preferredStyle: .alert)
                    let action1 = UIAlertAction(title: "Go To Calendar", style: .default, handler: { (action) -> Void in
                        let url = NSURL(string: "calshow:\(interval)")!
                        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                        self.performSegue(withIdentifier: "finish", sender: nil)
                    })
                    
                    let action2 = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                        self.performSegue(withIdentifier: "finish", sender: nil)
                    })
                    alert.addAction(action1)
                    alert.addAction(action2)
                    self.present(alert, animated: true, completion: nil)
                })
                
            } else {
                //we have error in getting access to device calendar
                print("error = \(String(describing: error?.localizedDescription))")
            }
        }
    }
    //Helper for showing alerts
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
    // Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        formatEvents()
    }
    //Ends the view from editing
    @objc func dismissKeyboard() {
        tableView.endEditing(true)
    }
}

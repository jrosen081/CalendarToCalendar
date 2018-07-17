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
}
class displayResults: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, GADInterstitialDelegate{
    
    //Calls all of the variables
    private var alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
    private let alarmPickerDate:[String] = ["No Alarm", "5 Minutes Before", "15 Minutes Before", "30 Minutes Before", "1 Hour Before", "2 Hours Before", "6 Hours Before", "1 Day Before", "2 Days Before", "1 Week Before"]
    @IBOutlet weak var tableView: UITableView!
    private let store = EKEventStore()
    var events: [Event] = [Event]()
    private var incorrect = 0
    private var wrongEvents = [Event]()
    private let testDevices: [Any] = [kGADSimulatorID]
    var advertisement: GADInterstitial!
    private var activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var adState: LoadState = .began
    override func viewDidLoad() {
        advertisement = GADInterstitial(adUnitID: "")
        self.activity.stopAnimating()
        createDismissedKeyboard()
        loadAd()
        super.viewDidLoad()
        setUpTableView()
        //Allows swipe to return
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.goBack(_:)))
        swipe.cancelsTouchesInView = false
        swipe.direction = .right
        self.view.addGestureRecognizer(swipe)
        showAlert(title: "Hint:", message: "Click on the name of the event to change it!"){(action) -> Void  in
                self.showIncorrectEvents()
            }
    }
    private func loadAd(){
        //Loads the advertisement
        let request = GADRequest()
        request.testDevices = self.testDevices
        advertisement.load(request)
        advertisement.delegate = self
    }
    private func setUpTableView(){
        //Displays the table view
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 200
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = UIColor.black
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    @IBAction func signOut(_ sender: Any) {
        self.signOut()
    }
    
    //When it stops editing, puts information into events
    func textViewDidEndEditing(_ textView: UITextView)
    {
        changeText(events[Int(textView.restorationIdentifier!)!], name:textView.text)
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
    //Changes the name of the event
    func changeText(_ event: Event, name: String){
        for counter in 0 ..< events.count{
            if (events[counter] == event){
                events[counter].name = name
            }
        }
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
            changeAlarm(events[Int(identifier)!], alarm: row)
        }
    }
    func changeAlarm(_ event: Event, alarm: Int){
        for counter in 0 ..< events.count{
            if (events[counter] == event){
                events[counter].alarm = alarm
                for cell in tableView.visibleCells{
                    if (tableView.indexPath(for: cell)?.row == counter){
                        (tableView.cellForRow(at: tableView.indexPath(for: cell)!) as! customcell).alarmPicker.selectRow(alarm, inComponent: 0, animated: true)
                    }
                }
            }
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
                        self.events[counter].alarm = checker
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
                    self.events[counter].name = self.alert.textFields![0].text!
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
            let dayOfWeek = getDayOfWeek(date: startDateParts[0]).0
            let startFormatted = "\(dayOfWeek), \(startDateParts[0])"
            showAlert(title: "Your Event", message: "\(name)starts on \(startFormatted) and is an all day event, and \(alarmData)")
        }
        else{
            let index1 = cell.startDate.text!.index(cell.startDate.text!.startIndex, offsetBy: 7)
            let startDateSuffix = cell.startDate.text![index1...]
            let startDate = String(startDateSuffix)
            let startDateParts: [String] = startDate.components(separatedBy: ", ")
            let dayOfWeek = getDayOfWeek(date: startDateParts[0])
            let startFormatted = "\(dayOfWeek.0), \(startDateParts[0]) at \(startDateParts[1])"
            let index2 = cell.endDate.text!.index(cell.endDate.text!.startIndex, offsetBy: 5)
            let endDateSuffix = cell.endDate.text![index2...]
            let endDate = String(endDateSuffix)
            let endDateParts: [String] = endDate.components(separatedBy: ", ")
            if (endDateParts[0] != startDateParts[0])
            {
                let dayOfEndDay = getDayOfWeek(date: endDateParts[0])
                let endFormatted = "\(dayOfEndDay.0), \(endDateParts[0]) at \(endDateParts[1])"
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
        let event = events[indexPath.row]
        cell.contentView.backgroundColor = UIColor.white
        cell.sizeToFit()
        cell.nameOfEvent.delegate = self
        cell.nameOfEvent.text = event.name
        cell.nameOfEvent.allowsEditingTextAttributes = true
        if (event.isAllDay)
        {
            cell.startDate.text = event.formattedStartDate
            cell.endDate.text = "All Day"
        }
        else
        {
            cell.startDate.text = "Start: \(event.formattedStartDate)"
            cell.endDate.text = "End: \(event.formattedEndDate)"
        }
        cell.alarmPicker.dataSource = self
        cell.alarmPicker.delegate = self
        cell.alarmPicker.reloadAllComponents()
        cell.alarmPicker.selectRow(event.alarm, inComponent: 0, animated: false)
        cell.alarmPicker.restorationIdentifier = String(describing: indexPath.row)
        cell.nameOfEvent.restorationIdentifier = String(describing: indexPath.row)
        events[indexPath.row] = event
        if (indexPath.row < incorrect){
            cell.layer.borderColor = UIColor.red.cgColor
            cell.layer.borderWidth = 2
        }
        else{
            cell.layer.borderWidth = 0
            cell.layer.borderColor = UIColor.clear.cgColor
        }
        return cell
    }
    //Method to Remove an Event
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let info = events.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.none)
            if let index = events.index(where: {$0 == info}){
                events.remove(at: index)
                tableView.deleteRows(at: [IndexPath(item: Int(index), section: 0)], with: .none)
                incorrect -= 1
            }
            tableView.endUpdates()
            if (events.count == 0)
            {
                DispatchQueue.main.async(execute: {
                    self.showAlert(title: "You have no events chosen.", message: ""){(action) -> Void in
                        self.performSegue(withIdentifier: "finish", sender: nil)
                    }
                })
                
            }else {
                for cell in tableView.visibleCells as! Array<customcell>
                {
                    let indexPath: IndexPath = tableView.indexPath(for: cell)!
                    cell.alarmPicker.restorationIdentifier = String(describing: indexPath.row)
                    cell.nameOfEvent.restorationIdentifier = String(describing: indexPath.row)
                    if (indexPath.row < incorrect){
                        cell.layer.borderWidth = 2
                        cell.layer.borderColor = UIColor.red.cgColor
                    }
                    else{
                        cell.layer.borderWidth = 0
                        cell.layer.borderColor = UIColor.clear.cgColor
                    }
                }
            }
        }
    }
    func getDayOfWeek(date: String) -> (String, Int)
    {
        let calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateDate = dateFormatter.date(from: date)!
        let dayOfWeek = calendar.component(.weekday, from: dateDate)
        return (dateFormatter.weekdaySymbols[dayOfWeek - 1], dayOfWeek)
    }
    //Displays advertisement
    @IBAction func addEvents(_ sender: Any) {
        DispatchQueue.main.async{
            switch self.adState{
                case .began:
                    if !self.activity.isAnimating{
                        self.view.addSubview(self.activity)
                        self.activity.startAnimating()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        self.addEvents(self.tableView)
                    })
                    break
                case .failed:
                    self.formatEvents()
                    break
                case .ready:
                    self.advertisement.present(fromRootViewController: self)
                    break
            }
        }
    }
    //Formats events to prepare for putting it into calendar
    func formatEvents()
    {
        for counter in 0 ..< events.count
        {
            var event = self.events[counter]
            switch event.alarm
            {
            case 1:
                event.alarm = -300
                break
            case 2:
                event.alarm = -900
                break
            case 3:
                event.alarm = -1800
                break
            case 4:
                event.alarm = -3600
                break
            case 5:
                event.alarm = -7200
                break
            case 6:
                event.alarm = -21600
                break
            case 7:
                event.alarm = -86400
                break
            case 8:
                event.alarm = -172800
                break
            case 9:
                event.alarm = -604800
                break
            default:
                 break
            }
            self.events[counter] = event
        }
        addEventToCalendar(events: events)
    }
    //Adds events to calendar
    func addEventToCalendar(events: [Event]) {
        let dateForCal = events[0].startDate
        var newEvents = [Event]()
        newEvents.append(contentsOf: events)
        newEvents.removeFirst(self.incorrect)
        let interval: TimeInterval = dateForCal.timeIntervalSinceReferenceDate
        store.requestAccess(to: .event) { (success, error) in
            if  error == nil {
                for event1 in newEvents {
                    let event = EKEvent(eventStore: self.store)
                    event.title = event1.name
                    event.calendar = self.store.defaultCalendarForNewEvents// this will return deafult calendar from device calendars
                    event.startDate = event1.startDate
                    if (event1.isAllDay)
                    {
                        event.isAllDay = true;
                        event.endDate = event.startDate
                    }
                    else{
                        event.endDate = event1.endDate
                    }
                    if (event1.alarm != 0)
                    {
                        let date: Date = Date.init(timeInterval: TimeInterval(event1.alarm), since: event1.startDate)
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
                        DispatchQueue.main.async{
                            let url = NSURL(string: "calshow:\(interval)")!
                            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                            self.performSegue(withIdentifier: "finish", sender: nil)
                        }
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
    // Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        DispatchQueue.main.async{
            self.formatEvents()
        }
    }
    @objc func goBack(_ sender: UISwipeGestureRecognizer)
    {
        self.performSegue(withIdentifier: "finish", sender: nil)
    }
    func sort(){
        DispatchQueue.global(qos: .userInitiated).async{
            var sorted = [(Int, Int)]()
            let stringFormatter = DateFormatter()
            stringFormatter.dateFormat = "MM/dd/yyyy"
            for event in self.events{
                sorted.append((self.getDayOfWeek(date: stringFormatter.string(from: event.startDate)).1, Calendar.current.component(.hour, from: event.startDate)))
            }
            var added = 0
            var badEvents = [Event]()
            for counter in 1 ... 7{
                let filtered = sorted.filter({$0.0 == counter})
                if (filtered.count > 2)
                {
                    let index = self.returnIndices(events: filtered)
                    if (!index.isEmpty)
                    {
                        for counter in 0 ..< index.count{
                            if let eventIndex = sorted.index(where: {$0.0 == index[counter].0 && $0.1 == index[counter].1}){
                                badEvents.append(self.events[Int(eventIndex) + added])
                                added += 1
                                sorted.remove(at: eventIndex)
                            }
                        }
                    }
                }
            }
            if (added > 0)
            {
                self.wrongEvents = badEvents
            }
        }
    }
    func returnIndices(events: [(Int, Int)]) -> [(Int, Int)]
    {
        var intArray = [Int]()
        var returnArray = [(Int, Int)]()
        for counter in 0 ..< events.count{
            intArray.append(events.filter({$0.1 == events[counter].1}).count)
        }
        var array = intArray.filter({$0 == 1})
        if (array.count >= 1 && array.count <= events.count / 2)
        {
            while (!array.isEmpty){
                if let index = intArray.index(where: {$0 == 1}){
                    returnArray.append(events[index])
                    array.removeFirst()
                }
                
            }
        }
        return returnArray
    }
    func showIncorrectEvents(){
        if (self.wrongEvents.count != 0)
        {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Would you like to see suggestions of incorrect events?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                let yes = UIAlertAction(title: "Yes", style: .default, handler: {(action) -> Void in
                    for counter in 0 ..< self.wrongEvents.count{
                        self.events.insert(self.wrongEvents[counter], at: counter)
                    }
                    self.incorrect = self.wrongEvents.count
                    self.tableView.reloadData()
                })
                let no = UIAlertAction(title: "No", style: .default, handler: nil)
                alert.addAction(no)
                alert.addAction(yes)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        self.adState = .failed
        debugPrint("\(error.debugDescription)")
    }
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        debugPrint("Got ad here")
        self.adState = .ready
    }
}

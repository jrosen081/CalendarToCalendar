import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class PartialView: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, GIDSignInDelegate, GIDSignInUIDelegate, UITextFieldDelegate {
    
    //Global variables
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var picker: UIPickerView!
    var pickerData:[String] = [String]()
    private let scopes = [kGTLRAuthScopeCalendar]
    private let service = GTLRCalendarService()
    @IBOutlet weak var label: UITextField!
    private var events: [[String]] = [[String]]()
    var calendars: [GTLRCalendar_CalendarListEntry] = [GTLRCalendar_CalendarListEntry]()
    override func viewDidLoad() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PartialView.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        super.viewDidLoad()
        //Sets up pickers
        self.picker.delegate = self
        self.picker.dataSource = self
        self.picker.reloadAllComponents()
        self.startDate.minimumDate = Date()
        self.endDate.minimumDate = Date()
        self.label.delegate = self
    }
    //Signs in to google
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.service.authorizer = user.authentication.fetcherAuthorizer()
        }
    }
    //Gets events using given criteria when selected
    @IBAction func getEvents(_ sender: Any) {
        if (self.label.text == "")
        {
            showAlert(title: "Please fill out the name of the event", message: "")
            return
        }
        fetchEvents()
    }
    // Makes sure the end date is not before start date
    @IBAction func changeEndDate(_ sender: Any) {
        self.endDate.minimumDate = self.startDate.date
    }
    //Gets events using criteria
    func fetchEvents() {
        var calendarID: String = ""
        for calendar in calendars
        {
            if (self.pickerData[picker.selectedRow(inComponent: 0)].description == calendar.summary!)
            {
                calendarID = calendar.identifier!
            }
        }
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: calendarID)
        query.timeMin = GTLRDateTime.init(date: self.startDate.date)
        query.timeMax = GTLRDateTime.init(date: self.endDate.date)
        query.orderBy = "startTime"
        query.singleEvents = true
        query.q = label.text!
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
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        if let events = response.items, !events.isEmpty {
            for event in events {
                if let start = event.start!.dateTime {
                    let end = event.end!.dateTime!
                    let dateFromStringFormatter = DateFormatter()
                    dateFromStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    let StringFromDateFormatter = DateFormatter()
                    StringFromDateFormatter.dateFormat = "mm/dd/yyy, HH:MM a"
                    let date = dateFromStringFormatter.date(from: start.rfc3339String)
                    let enddate = dateFromStringFormatter.date(from: end.rfc3339String)
                    var userVisibleDateTimeString: String!
                    var endDate: String!
                    let userVisibleDateFormatter = DateFormatter()
                    userVisibleDateFormatter.dateStyle = DateFormatter.Style.short
                    userVisibleDateFormatter.timeStyle = DateFormatter.Style.short
                    userVisibleDateTimeString = userVisibleDateFormatter.string(from: date!)
                    endDate = userVisibleDateFormatter.string(from: enddate!)
                    let string1: [String] = [start.rfc3339String, end.rfc3339String, event.summary!, userVisibleDateTimeString, endDate]
                    self.events.append(string1)
                }
                else
                {
                    let start = event.start!.date!
                    let dateFromStringFormatter = DateFormatter()
                    dateFromStringFormatter.dateFormat = "yyyy-MM-dd"
                    let StringFromDateFormatter = DateFormatter()
                    StringFromDateFormatter.dateFormat = "mm/dd/yyyy"
                    let date = dateFromStringFormatter.date(from: start.rfc3339String)
                    var userVisibleDateTimeString: String!
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
                    userVisibleDateTimeString = userVisibleDateFormatter.string(from: date!)
                    let string1: [String] = ["\(start.rfc3339String)T00:00:00\(timeZoneString):00", "\(start.rfc3339String)T00:00:00\(timeZoneString):00", event.summary!, userVisibleDateTimeString, "All Day"]
                    self.events.append(string1)
                }
            }
            performSegue(withIdentifier: "displayResults", sender: nil)
        } else {
            showAlert(title: "Error", message: "There are no events in that time that are titled \(self.label.text!)")
        }
        
    }
    
    //Signs Out
    @IBAction func signOut(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure?", message: "You will need to sign back in before using the app.", preferredStyle: .alert)
        let signOut = UIAlertAction(title: "Sign Out", style: .default, handler: { (action) -> Void in
            GIDSignIn.sharedInstance().signOut()
            self.performSegue(withIdentifier: "signedOut", sender: nil)
            })
        signOut.setValue(UIColor.red, forKey: "titleTextColor")
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) -> Void in })
        alert.addAction(cancel)
        alert.addAction(signOut)
        DispatchQueue.main.async(execute: {self.present(alert, animated: true, completion: nil)})
        
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
    //Gets rid of text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    //Picker view functions
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    //Ends the view from editing
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    //Sends events to next file
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? displayResults {
            viewControllerB.events = self.events
        }
    }
    
}

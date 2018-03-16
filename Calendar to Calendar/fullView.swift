import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class fullView: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, GIDSignInDelegate, GIDSignInUIDelegate {
    //Global variables
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var picker: UIPickerView!
    var pickerData:[String] = [String]()
    private let scopes = [kGTLRAuthScopeCalendar]
    private let service = GTLRCalendarService()
    private var events: [[String]] = [[String]]()
    var calendars: [GTLRCalendar_CalendarListEntry] = [GTLRCalendar_CalendarListEntry]()
    override func viewDidLoad() {
        //Sign in to google
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        //Start the shown pickers
        self.picker.delegate = self
        self.picker.dataSource = self
        self.picker.reloadAllComponents()
        self.startDate.minimumDate = Date()
        self.endDate.minimumDate = Date()
    }
    //Sign out of google
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
    //Sign in to google
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.service.authorizer = user.authentication.fetcherAuthorizer()
        }
    }
    //Get events using given criteria when clicked
    @IBAction func getEvents(_ sender: Any) {
        fetchEvents()
    }
    //Make sure that the end date is after the start date
    @IBAction func changeEndDate(_ sender: Any) {
        self.endDate.minimumDate = self.startDate.date
    }
    //Get events using criteria
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
        service.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    // Gets result of query and formats it
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
                    var userVisibleDateTimeString: String!
                    let userVisibleDateFormatter = DateFormatter()
                    userVisibleDateFormatter.dateStyle = DateFormatter.Style.short
                    userVisibleDateFormatter.timeStyle = DateFormatter.Style.short
                    userVisibleDateTimeString = userVisibleDateFormatter.string(from: date!)
                    let string1: [String] = ["\(start.rfc3339String)T00:00:00\(timeZoneString):00", "\(start.rfc3339String)T00:00:00\(timeZoneString):00", event.summary!, userVisibleDateTimeString, "All Day"]
                    self.events.append(string1)
                }
                
            }
            performSegue(withIdentifier: "hasDetails", sender: nil)
        } else {
            showAlert(title: "Error", message: "There are no events in that time.")
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
    //Sends events to next file
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? displayResults {
            viewControllerB.events = self.events
        }
    }
}


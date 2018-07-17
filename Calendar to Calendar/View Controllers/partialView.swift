import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class PartialView: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //Global variables
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var picker: UIPickerView!
    var pickerData:[String] = [String]()
    private let scopes = [kGTLRAuthScopeCalendar]
    private let service = GTLRCalendarService()
    @IBOutlet weak var label: UITextField!
    private var events: [Event] = [Event]()
    var calendars: [GTLRCalendar_CalendarListEntry] = [GTLRCalendar_CalendarListEntry]()
    private var google = GoogleInteractor.sharedInstance
    override func viewDidLoad() {
        createDismissedKeyboard()
        super.viewDidLoad()
        updateDelegates()
        setUpDatePickers(self.startDate, self.endDate)
        //self.picker.reloadAllComponents()
        google.errorDelegate = { error in
            self.showAlert(title: "Error", message: error.localizedDescription)
        }
        google.finishingClosure = { response in
            if let events = response as? [Event]{
                self.events = events
                DispatchQueue.main.async{
                    self.performSegue(withIdentifier: "displayResults", sender: nil)
                }
            }
        }
    }
    private func updateDelegates(){
        self.picker.delegate = self
        self.picker.dataSource = self
        self.label.delegate = self
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
            guard let _ = calendar.summary else {continue}
            if (self.pickerData[picker.selectedRow(inComponent: 0)].description == calendar.summary!)
            {
                calendarID = calendar.identifier!
            }
        }
        google.fetchEvents(name: self.label.text!, startDate: self.startDate.date, endDate: self.endDate.date, calendarID: calendarID)
    }
    
    //Signs Out
    @IBAction func signOut(_ sender: Any) {
       self.signOut()
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
    //Sends events to next file
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? displayResults {
            viewControllerB.events = self.events
            viewControllerB.sort()
        }
    }
    deinit{
        self.calendars.removeAll()
        self.pickerData.removeAll()
    }
}

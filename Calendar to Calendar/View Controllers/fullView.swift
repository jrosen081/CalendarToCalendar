import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class fullView: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource{
    //Global variables
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var picker: UIPickerView!
    var pickerData:[String] = [String]()
    private var events: [Event] = [Event]()
    var calendars: [GTLRCalendar_CalendarListEntry] = [GTLRCalendar_CalendarListEntry]()
    let googleUser = GoogleInteractor.sharedInstance
    override func viewDidLoad() {
        setUpDatePickers(self.startDate, self.endDate)
        updateDelegates()
        googleUser.delegate = self
    }
    func updateDelegates(){
        self.picker.delegate = self
        self.picker.dataSource = self
    }
    //Sign out of google
    @IBAction func signOut(_ sender: Any) {
        self.signOut()
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
        if let index = calendars.index(where: {$0.summary != nil && $0.summary! == self.pickerData[picker.selectedRow(inComponent: 0)].description}){
            calendarID = calendars[index].identifier!
        }
        googleUser.fetchEvents(name: nil, startDate: self.startDate.date, endDate: self.endDate.date, calendarID: calendarID)
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
    deinit{
        self.calendars.removeAll()
        self.pickerData.removeAll()
    }
}
extension fullView: GoogleInteractionDelegate{
    func returnedError(error: CustomError) {
        self.showAlert(title: "Error", message: error.localizedDescription)
    }
    func returnedResults(data: Any) {
        if let events = data as? [Event]{
            self.events = events
            DispatchQueue.main.async{
                self.performSegue(withIdentifier: "displayResults", sender: nil)
            }
        }
    }
}


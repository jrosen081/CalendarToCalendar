import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class PartialView: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //Global variables
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var label: UITextField!
    private var events: [Event] = [Event]()
    var calendars = [Calendar]()
    private lazy var server = self.holder?.currentInteractor
	var holder: HoldingController?
    override func viewDidLoad() {
        createDismissedKeyboard()
        super.viewDidLoad()
        updateDelegates()
        setUpDatePickers(self.startDate, self.endDate)
        server?.delegate = self
		calendars.append(contentsOf: self.holder?.calendarHolder.calendars ?? [])
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
        if let index = calendars.firstIndex(where: {$0.name == self.calendars[picker.selectedRow(inComponent: 0)].name}){
            calendarID = calendars[index].identifier
        }
        server?.fetchEvents(name: self.label.text!, startDate: self.startDate.date, endDate: self.endDate.date, calendarID: calendarID)
    }
    
    //Signs Out
    @IBAction func signOut(_ sender: Any) {
       self.holder?.signOut(from: self)
    }
    //Gets rid of text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    //Picker view functions
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return calendars.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return calendars[row].name
    }
    //Sends events to next file
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? displayResults {
            viewControllerB.events = self.events
            viewControllerB.sort()
        }
    }

	@IBAction func sendBacktoChoose(_ sender: Any) {
		if let vc = self.storyboard?.instantiateViewController(withIdentifier: "chooseOption") as?  ChooseExport {
			vc.holder = self.holder
			self.holder?.transition(from: self, to: vc, with: .leftToRight)
		}
	}
}
extension PartialView: InteractionDelegate{
    func returnedError(error: CustomError) {
        self.showAlert(title: "Error", message: error.localizedDescription)
    }
    func returnedResults(data: Any) {
        if let events = data as? [Event]{
            self.events = events
            DispatchQueue.main.async{
				if let vc = self.storyboard?.instantiateViewController(withIdentifier: "displayResults") as? displayResults {
					vc.events = events
					vc.sort()
					vc.holder = self.holder
					self.holder?.transition(from: self, to: vc, with: .rightToLeft)
				}
            }
        }
    }
}

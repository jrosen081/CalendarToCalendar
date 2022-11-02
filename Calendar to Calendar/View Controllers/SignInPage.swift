

import GoogleSignIn
import UIKit
import GoogleAPIClientForREST
import StoreKit

class SignInPage: UIViewController {
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signIn: UILabel!
    @IBOutlet weak var googleSignIn: UIButton!
    @IBOutlet weak var outlookSignIn: UIButton!
	weak var holding: HoldingController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressIndicator.isHidden = true
        signIn.isHidden = true
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        progressIndicator.transform = transform
        googleSignIn.layer.cornerRadius = 10
        outlookSignIn.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let version = UserDefaults.standard.integer(forKey: "Version")
        if (version < 2){
            showAlert(title: "Hi, this app now supports both Google and Outlook Calendars.", message: "To switch between them, shake the screen. It will bring you back to the sign in page to change services.")
            UserDefaults.standard.set(2, forKey: "Version")
        }
    }
    
    @IBAction func signInUsingGoogle(_ sender: Any) {
		holding?.currentServer = .GOOGLE
		holding?.uiDelegate = self
		holding?.delegate = self
        signInWithServers()
    }
    
    @IBAction func signInUsingOutlook(_ sender: Any) {
		holding?.currentServer = .OUTLOOK
		holding?.delegate = self
        signInWithServers()
    }
    func signInWithServers(){
        toggleButtons(isHidden: true)
        holding?.currentInteractor.signIn(from: self)
    }

	func toggleButtons(isHidden: Bool){
        googleSignIn.isHidden = isHidden
        outlookSignIn.isHidden = isHidden
        self.signIn.isHidden = !isHidden
        self.progressIndicator.isHidden = !isHidden
    }
    //Sends to the next file
    func changePages()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
			guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "chooseOption") as? ChooseExport else {
				return
			}
			nextVC.serverUser = self.holding?.currentInteractor
			nextVC.holder = self.holding
			self.holding?.transition(from: self, to: nextVC, with: .rightToLeft)
        }
    }
    
}
extension SignInPage: InteractionDelegate{
    func returnedResults(data: Any) {
        DispatchQueue.main.async(execute:{
            self.changePages()
        })
    }
    func returnedError(error: CustomError) {
        self.showAlert(title: "Error", message: error.localizedDescription)
        toggleButtons(isHidden: false)
    }
}

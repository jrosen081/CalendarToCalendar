

import GoogleSignIn
import UIKit
import GoogleAPIClientForREST

class SignInPage: UIViewController, GIDSignInUIDelegate{
    // Global variables
    let googleSigner = GoogleInteractor.sharedInstance
    let outlookSigner = OutlookInteractor.sharedInstance
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signIn: UILabel!
    @IBOutlet weak var googleSignIn: UIButton!
    @IBOutlet weak var outlookSignIn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AdInteractor.currentViewController = self
        progressIndicator.isHidden = true
        signIn.isHidden = true
        googleSigner.uiDelegate = self
        googleSigner.delegate = self
        outlookSigner.delegate = self
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
        ServerInteractor.currentServer = .GOOGLE
        signInWithServers()
    }
    
    @IBAction func signInUsingOutlook(_ sender: Any) {
        ServerInteractor.currentServer = .OUTLOOK
        signInWithServers()
    }
    func signInWithServers(){
        toggleButtons(isHidden: true)
        ServerInteractor.current.signIn(from: self)
        AdInteractor.isSigningIn = true
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
            self.performSegue(withIdentifier: "PersonSignedIn", sender: nil)
        }
    }
    
}
extension SignInPage: InteractionDelegate{
    func returnedResults(data: Any) {
        AdInteractor.isSigningIn = false
        DispatchQueue.main.async(execute:{
            self.changePages()
        })
    }
    func returnedError(error: CustomError) {
        AdInteractor.isSigningIn = false
        self.showAlert(title: "Error", message: error.localizedDescription)
        toggleButtons(isHidden: false)
    }
}


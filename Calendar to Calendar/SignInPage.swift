

import GoogleSignIn
import UIKit
import GoogleAPIClientForREST

class SignInPage: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    

    // Global variables
    private let scopes = [kGTLRAuthScopeCalendar]
    private let service = GTLRCalendarService()
    let signInButton = GIDSignInButton()
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signIn: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = self.scopes
        progressIndicator.isHidden = true
        signIn.isHidden = true
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        progressIndicator.transform = transform;
        //Shows the progress bar if is signed in
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            progressIndicator.isHidden = false
            signIn.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                GIDSignIn.sharedInstance().signInSilently()
            }
        }
        //Shows button if not
        else{
            self.signInButton.center = self.view.center
            // Add the sign-in button.
            view.addSubview(signInButton)
        }
    }
    //Signs into google
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            DispatchQueue.main.async(execute:{
                self.signIn.isHidden = false
                self.progressIndicator.isHidden = false
                self.changePages()
            })
        }
    }
    //Sends to the next file
    func changePages()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "chooseOption")
            self.present(newViewController, animated: true, completion: nil)
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
}

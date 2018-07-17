

import GoogleSignIn
import UIKit
import GoogleAPIClientForREST

class SignInPage: UIViewController, GIDSignInUIDelegate {
    

    // Global variables
    let signInButton = GIDSignInButton()
    let signer = GoogleInteractor.sharedInstance
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signIn: UILabel!
    deinit{
        signer.finishingClosure = nil
        signer.errorDelegate = nil
        signer.signInUIDelegate = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        signer.signInUIDelegate = self
        signer.errorDelegate = {error in
            self.showAlert(title: "Error", message: error.localizedDescription)
        }
        signer.finishingClosure = { _ in
            DispatchQueue.main.async(execute:{
                self.signInButton.isHidden = true
                self.signIn.isHidden = false
                self.progressIndicator.isHidden = false
                self.changePages()
            })
        }
        progressIndicator.isHidden = true
        signIn.isHidden = true
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        progressIndicator.transform = transform;
        //Shows the progress bar if is signed in
        if signer.isSignedIn {
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
    //Sends to the next file
    func changePages()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.performSegue(withIdentifier: "PersonSignedIn", sender: nil)
        }
    }
}


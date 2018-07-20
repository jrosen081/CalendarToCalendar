

import GoogleSignIn
import UIKit
import GoogleAPIClientForREST

class SignInPage: UIViewController{
    // Global variables
    let signInButton = GIDSignInButton()
    let signer = GoogleInteractor.sharedInstance
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signIn: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
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
        signer.delegate = self
    }
    //Sends to the next file
    func changePages()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.performSegue(withIdentifier: "PersonSignedIn", sender: nil)
        }
    }
    
}
extension SignInPage: GoogleInteractionDelegate{
    func returnedResults(data: Any) {
        DispatchQueue.main.async(execute:{
            self.signInButton.isHidden = true
            self.signIn.isHidden = false
            self.progressIndicator.isHidden = false
            self.changePages()
        })
    }
    func returnedError(error: CustomError) {
        self.showAlert(title: "Error", message: error.localizedDescription)
    }
}


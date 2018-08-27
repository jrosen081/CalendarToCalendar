

import GoogleSignIn
import UIKit
import GoogleAPIClientForREST
import StoreKit

class SignInPage: UIViewController, GIDSignInUIDelegate{
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signIn: UILabel!
    @IBOutlet weak var googleSignIn: UIButton!
    @IBOutlet weak var outlookSignIn: UIButton!
    @IBOutlet weak var restorePurchaseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AdInteractor.currentViewController = self
        progressIndicator.isHidden = true
        signIn.isHidden = true
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        progressIndicator.transform = transform
        googleSignIn.layer.cornerRadius = 10
        outlookSignIn.layer.cornerRadius = 10
        restorePurchaseButton.layer.cornerRadius = 10
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
        GoogleInteractor.sharedInstance.uiDelegate = self
        ServerInteractor.current.delegate = self
        signInWithServers()
    }
    
    @IBAction func signInUsingOutlook(_ sender: Any) {
        ServerInteractor.currentServer = .OUTLOOK
        ServerInteractor.current.delegate = self
        signInWithServers()
    }
    func signInWithServers(){
        toggleButtons(isHidden: true)
        ServerInteractor.current.signIn(from: self)
        AdInteractor.isSigningIn = true
    }
    
    
    @IBAction func restorePurchases(_ sender: Any) {
        if (SKPaymentQueue.canMakePayments()) {
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
            print("here")
        }
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
extension SignInPage: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .restored || transaction.transactionState == .purchased {
                AdInteractor.isAdFree = true
                queue.finishTransaction(transaction)
            } else if transaction.transactionState == .failed {
                queue.finishTransaction(transaction)
            }
            print(transaction)
        }
        //showAlert(title: "Purchases have been restored.")
    }
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        showAlert(title: "Purchases have been restored.")
    }
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        showAlert(title: "Purchases have been restored.")
        print(error.localizedDescription)
    }
}


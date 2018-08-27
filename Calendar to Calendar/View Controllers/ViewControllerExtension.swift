//
//  ViewControllerExtension.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 7/16/18.
//  Copyright © 2018 Jack Rosen. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

extension UIViewController{
    //Allows it to be the first responder
    override open var canBecomeFirstResponder: Bool{
        return true
    }
    //Sends the user back to the starting page on shake
    override open func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if (motion == .motionShake) {
            if self.classForCoder != SignInPage.classForCoder(){
                let alert = UIAlertController(title: "Do you want to return to the sign in screen?", message: "You will be sent back to the starting screen, but not signed out.", preferredStyle: .alert)
                let signOut = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                    self.performSegue(withIdentifier: "signedOut", sender: nil)
                })
                let cancel = UIAlertAction(title: "No", style: .cancel)
                alert.addAction(cancel)
                alert.addAction(signOut)
                DispatchQueue.main.async(execute: {self.present(alert, animated: true, completion: nil)})
            }
        }
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String = "", closure: ((UIAlertAction) -> ())? = nil) {
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: UIAlertControllerStyle.alert
            )
            let ok = UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.default,
                handler: closure
            )
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        })
    }
    //Ends the view from editing
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    //Creates a tap gesture to dismiss the keyboard
    func createDismissedKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    //Makes date pickers have the minimum date as today
    func setUpDatePickers(_ pickers: UIDatePicker...){
        pickers.forEach({$0.minimumDate = Date()})
    }
    //Signs Out
    func signOut() {
        let alert = UIAlertController(title: "Are you sure?", message: "You will need to sign back in before using the app.", preferredStyle: .alert)
        let signOut = UIAlertAction(title: "Sign Out", style: .default, handler: { (action) -> Void in
            ServerInteractor.current.signOut()
            self.performSegue(withIdentifier: "signedOut", sender: nil)
        })
        signOut.setValue(UIColor.red, forKey: "titleTextColor")
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) -> Void in })
        alert.addAction(cancel)
        alert.addAction(signOut)
        DispatchQueue.main.async(execute: {self.present(alert, animated: true, completion: nil)})
    }
    
}
extension UIViewController: AdFreeDelegate {
    
    
    //Shows the ad screen and lets the users see it
    func showAdFree(){
        let alert = UIAlertController(title: "Do you want to buy the ad free version?", message: "", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default, handler: {action in
            let mainController = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainController.instantiateViewController(withIdentifier: "AdFree") as! AdFreeViewController
            AdInteractor.currentViewController = viewController
            AdInteractor.isSigningIn = true
            viewController.adFreeDelegate = self
            if let this = self as? SKPaymentTransactionObserver {
                SKPaymentQueue.default().remove(this)
            }
            self.present(viewController, animated: true)
        })
        let no = UIAlertAction(title: "No", style: .default)
        alert.addAction(no)
        alert.addAction(yes)
        self.present(alert, animated: true, completion: nil)
    }
    func adFreeBought() {
        AdInteractor.isSigningIn = false
        SKPaymentQueue.default().remove(AdInteractor.currentViewController as! SKPaymentTransactionObserver)
        AdInteractor.currentViewController?.dismiss(animated: true)
        self.showAlert(title: "Congratulations", message: "You have succesfully bought the ad free version of the app.")
        UserDefaults.standard.set(30, forKey: "totalAdsShown")
        AdInteractor.currentViewController = self
    }
    
    func adFreeCanceled() {
        AdInteractor.isSigningIn = false
        SKPaymentQueue.default().remove(AdInteractor.currentViewController as! SKPaymentTransactionObserver)
        AdInteractor.currentViewController?.dismiss(animated: true)
        self.showAlert(title: ":(", message: "Sorry to hear that you do not want the ad free version. There will be another opportunity if you want it")
        AdInteractor.currentViewController = self
    }
}

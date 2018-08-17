//
//  ViewControllerExtension.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 7/16/18.
//  Copyright © 2018 Jack Rosen. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    //Allows it to be the first responder
    override open var canBecomeFirstResponder: Bool{
        return true
    }
    //Sends the user back to the starting page on shake
    override open func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if (motion == .motionShake) {
            if self.classForCoder != SignInPage.classForCoder(){
                let alert = UIAlertController(title: "Do you want to return to the sign in screen?", message: "You will be sent back to the starting screen, but not signed out", preferredStyle: .alert)
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

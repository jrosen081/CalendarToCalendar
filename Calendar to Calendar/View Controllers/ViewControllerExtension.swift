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
    
    // Helper for showing an alert
    func showAlert(title : String, message: String = "", closure: ((UIAlertAction) -> ())? = nil) {
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: UIAlertController.Style.alert
            )
            let ok = UIAlertAction(
                title: "OK",
                style: UIAlertAction.Style.default,
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
}

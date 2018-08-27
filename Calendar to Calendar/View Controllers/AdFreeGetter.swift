//
//  AdFreeGetter.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen (New User) on 8/23/18.
//  Copyright © 2018 Jack Rosen. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class AdFreeViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    let productID: Set<String> = ["com.JackRosen.calendartocalendar.adfreeversion"]
    var products: [SKProduct] = []
    var adFreeDelegate: AdFreeDelegate?
    let alertController = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //Gets the information about the products
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productRequest = SKProductsRequest(productIdentifiers: productID)
            productRequest.delegate = self
            productRequest.start()
        }
        else {
            print("Cannot perform In App Purchases.")
        }
    }
    
    override func viewDidLoad() {
        requestProductInfo()
        SKPaymentQueue.default().add(self)
        alertController.transform = CGAffineTransform(scaleX: 3, y: 3)
        buyButton.layer.cornerRadius = buyButton.frame.height / 10
        cancelButton.layer.cornerRadius = cancelButton.frame.height / 10
    }
    //This is the response if there
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if (response.products.count > 0) {
            products.append(contentsOf: response.products)
        } else if (response.invalidProductIdentifiers.count > 0){
            //If there is an issue getting data from the server, display it and return to the home screen
            self.showAlert(title: "There was an issue with getting the purchase.") { _ in
                self.adFreeDelegate?.adFreeCanceled()
            }
            
        }
    }
    //Error delegate method
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.showAlert(title: "There was an issue with getting the purchase.") { _ in
            self.adFreeDelegate?.adFreeCanceled()
        }
        print(error.localizedDescription)
    }
    //This checks the payment to see if the transaction was failed or purchased
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if (transaction.transactionState == .failed) {
                SKPaymentQueue.default().finishTransaction(transaction)
                adFreeDelegate?.adFreeCanceled()
            } else if (transaction.transactionState == .purchased) {
                SKPaymentQueue.default().finishTransaction(transaction)
                AdInteractor.isAdFree = true
                adFreeDelegate?.adFreeBought()
            }
        }
    }
    
    //The cancel button was selected
    @IBAction func cancel(_ sender: Any) {
        adFreeDelegate?.adFreeCanceled()
    }
    //The buy button was selected
    @IBAction func buyAdFree(_ sender: Any) {
        payForAdFree()
    }
    //This function has them pay for the ad free version of the app
    private func payForAdFree() {
        let payment = SKPayment(product: products[0])
        SKPaymentQueue.default().add(payment)
        self.view.addSubview(alertController)
    }
}

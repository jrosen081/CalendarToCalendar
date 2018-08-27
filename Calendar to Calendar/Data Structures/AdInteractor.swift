//
//  AdInteractor.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 8/13/18.
//  Copyright © 2018 Jack Rosen. All rights reserved.
//

import Foundation
import GoogleMobileAds

class AdInteractor: NSObject {
    //Test: ca-app-pub-3940256099942544/4411468910
    //Production: ca-app-pub-1472286068235914/8440163507
    private static let delegate = AdInteractor()
    static var adState = LoadState.none
    static var currentViewController: UIViewController?
    private static var _interstitial = GADInterstitial(adUnitID: "YOUR_ID_HERE")
    static var interstitial: GADInterstitial {
        get {
            if (_interstitial.hasBeenUsed){
                 _interstitial = GADInterstitial(adUnitID: "YOUR_ID_HERE")
            }
            switch adState {
            case .ready, .began:
                return _interstitial
            default:
                let request = GADRequest()
                //request.testDevices = testDevices
                _interstitial.load(request)
                _interstitial.delegate = delegate
                adState = .began
                return _interstitial
            }
        }
    }
    static var isSigningIn = false
    /**
     A boolean to decide if the user is ad free. This is stored in local defaults
     */
    static var isAdFree: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "UserHasAdFree")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UserHasAdFree")
        }
    }
}
extension AdInteractor: GADInterstitialDelegate{
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        AdInteractor.adState = .ready
    }
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        AdInteractor.adState = .none
        var totalAds = UserDefaults.standard.integer(forKey: "totalAdsShown")
        totalAds += 1
        if (totalAds >= 10 ) {
            AdInteractor.currentViewController?.showAdFree()
            totalAds = 0
        }
        UserDefaults.standard.set(totalAds, forKey: "totalAdsShown")
    }
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        AdInteractor.adState = .failed
    }
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        AdInteractor.adState = .none
    }
}

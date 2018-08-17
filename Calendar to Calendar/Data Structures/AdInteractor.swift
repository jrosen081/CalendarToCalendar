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
    private static var _interstitial = GADInterstitial(adUnitID: "YOUR_AD_UNIT_ID")
    static var interstitial: GADInterstitial {
        get {
            if (_interstitial.hasBeenUsed){
                 _interstitial = GADInterstitial(adUnitID: "YOUR_AD_UNIT_ID")
            }
            switch adState {
            case .ready, .began:
                return _interstitial
            default:
                let request = GADRequest()
                request.testDevices = testDevices
                _interstitial.load(request)
                _interstitial.delegate = delegate
                adState = .began
                return _interstitial
            }
        }
    }
    static var isSigningIn = false
}
extension AdInteractor: GADInterstitialDelegate{
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        AdInteractor.adState = .ready
    }
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        AdInteractor.adState = .none
    }
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        AdInteractor.adState = .failed
    }
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        AdInteractor.adState = .none
    }
}

import Google
import GoogleSignIn
import UIKit
import GoogleMobileAds
import UserNotifications

 let testDevices: [Any] = [kGADSimulatorID, "8d7f75d1a627b54e81099ff4bb2e9ac4", "67565bf06bc7fc00e6e6ec5196828417"]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    var window: UIWindow?
    
    var interstitial: GADInterstitial?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        Thread.sleep(forTimeInterval: 1.0)
        
        GADMobileAds.configure(withApplicationID: "YOUR_ID_HERE")
        GADMobileAds.sharedInstance().applicationMuted = true
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {(success, error) in
            if let error = error{
                print(error.localizedDescription)
            }
        })
        
        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        return true
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.scheme == "CalendarToCalendar" {
            let service = OutlookInteractor.sharedInstance
            service.handleOAuthCallback(url: url)
            return true
        } else {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication: sourceApplication,
                                                     annotation: annotation)
        }
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        //If it is this scheme, it is coming from Outlook
        if url.scheme?.lowercased() == "CalendarToCalendar".lowercased() {
            let service = OutlookInteractor.sharedInstance
            let newUrl = url.absoluteString.replacingOccurrences(of: "calendartocalendar", with: "CalendarToCalendar")
            service.handleOAuthCallback(url: URL(string: newUrl)!)
            return true
        }
        //Else the scheme is coming from Google
        else {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication: sourceApplication,
                                                     annotation: annotation)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        //If the user is not signing in and does not have the ad free version, load the ad
        if (!AdInteractor.isSigningIn && !AdInteractor.isAdFree){
            interstitial = AdInteractor.interstitial
        } else {
            print("Not active")
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        //If the user is not signing in and the user is not ad free, show the ad
        if !AdInteractor.isSigningIn, !AdInteractor.isAdFree, let controller = AdInteractor.currentViewController, let intersitial = interstitial, intersitial.isReady {
            interstitial?.present(fromRootViewController: controller)
        } else {
            print("Back to active")
        }
    }
}


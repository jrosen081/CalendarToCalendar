import GoogleSignIn
import SwiftUI
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var service: OutlookInteractor?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        window = UIWindow()
        window?.makeKeyAndVisible()

		let notificationCenter = UNUserNotificationCenter.current()
		notificationCenter.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {(_, error) in
			if let error = error {
				print(error.localizedDescription)
            } else {
                self.createNotification()
            }
		})
        CurrentServer.allCases.forEach { $0.interactor.tryToSignInSilently() }
        window?.rootViewController = UIHostingController(rootView: MainView())
		return true
	}

    private func createNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Your Calendar needs updating."
        content.body = "Come back to Calendar to Calendar to update your iPhone calendar with Google events."
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let dateComponents = DateComponents(calendar: Foundation.Calendar.autoupdatingCurrent, timeZone: TimeZone.current, day: 1)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "COMEBACK", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if let error = error {
                print(error.localizedDescription)
            }
        })
    }

	func application(_ app: UIApplication, open url: URL,
					 options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
		// If it is this scheme, it is coming from Outlook
		if url.scheme?.lowercased() == "CalendarToCalendar".lowercased() {
			let newUrl = url.absoluteString.replacingOccurrences(of: "calendartocalendar", with: "CalendarToCalendar")
			service?.handleOAuthCallback(url: URL(string: newUrl)!)
			return true
		}
		// Else the scheme is coming from Google
		else {
			return GIDSignIn.sharedInstance.handle(url)
		}
	}
}

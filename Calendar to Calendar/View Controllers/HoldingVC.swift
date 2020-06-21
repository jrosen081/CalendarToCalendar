//
//  HoldingVC.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 4/25/19.
//  Copyright © 2019 Jack Rosen. All rights reserved.
//

import UIKit
import GoogleSignIn
import StoreKit

class HoldingVC: UIViewController, HoldingController, CalendarHolder {
	private lazy var googleInteractor: GoogleInteractor = GoogleInteractor(holder: self)
	private lazy var outlookInteractor: OutlookInteractor = OutlookInteractor(holder: self)
	var currentServer = CurrentServer.GOOGLE
	var uiDelegate: GIDSignInUIDelegate? {
		get {
			return googleInteractor.uiDelegate
		}
		set {
			googleInteractor.uiDelegate = newValue
		}
	}
	
	private var googleCalendars = [Calendar]()
	private var outlookCalendars = [Calendar]()
	var calendars: [Calendar] {
		get {
			if self.currentServer == .GOOGLE {
				return self.googleCalendars
			} else {
				return self.outlookCalendars
			}
		}
		set {
			if self.currentServer == .GOOGLE {
				self.googleCalendars.removeAll()
				self.googleCalendars.append(contentsOf: newValue)
			} else {
				self.outlookCalendars.removeAll()
				self.outlookCalendars.append(contentsOf: newValue)
			}
		}
	}
	
	lazy var calendarHolder: CalendarHolder = self
	
	var delegate: InteractionDelegate? {
		get {
			return self.currentInteractor.delegate
		}
		set {
			self.currentInteractor.delegate = newValue
		}
	}
	
	var currentInteractor: APIInteractor {
		if self.currentServer == .GOOGLE {
			return self.googleInteractor
		} else {
			return self.outlookInteractor
		}
	}
	
	private var currentVC = UIViewController(nibName: nil, bundle: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
		if let controller = self.storyboard?.instantiateViewController(withIdentifier: "signIn") as? SignInPage {
			self.addChild(controller)
			controller.view.frame = self.view.frame
			controller.holding = self
			self.view.addSubview(controller.view)
			currentVC = controller
		}
		if let app = UIApplication.shared.delegate as? AppDelegate {
			app.service = self.outlookInteractor
		}
    }
	
	/// Transitions from one VC to another
	func transition(from: UIViewController, to: UIViewController, with transition: Transition = .rightToLeft) {
		currentVC = to
		from.removeFromParent()
		self.addChild(to)
		to.view.frame = self.view.frame
		self.view.insertSubview(to.view, at: 0)
		UIView.animate(withDuration: 0.5, animations: {
			from.view.frame = CGRect(x: self.view.bounds.width * CGFloat(transition.rawValue), y: 0, width: from.view.frame.width, height: from.view.frame.height)
		}, completion: { _ in from.view.removeFromSuperview()})
	}
		
	/// Signs out the given account
	func signOut(from controller: UIViewController) {
		let alert = UIAlertController(title: "Are you sure?", message: "You will need to sign back in before using the app.", preferredStyle: .alert)
		let signOut = UIAlertAction(title: "Sign Out", style: .default, handler: { (action) -> Void in
			self.currentInteractor.signOut()
			if let controller2 = self.storyboard?.instantiateViewController(withIdentifier: "signIn") as? SignInPage {
				controller2.holding = self
				self.transition(from: controller, to: controller2)
			}
		})
		signOut.setValue(UIColor.red, forKey: "titleTextColor")
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) -> Void in })
		alert.addAction(cancel)
		alert.addAction(signOut)
		DispatchQueue.main.async(execute: {controller.present(alert, animated: true, completion: nil)})
		
	}
	
	/// Adds a calendar to the list
	func addCalendar(calendar: Calendar) {
		self.calendars.append(calendar)
	}
	
	/// Removes all calendars
	func removeAll() {
		self.calendars.removeAll()
	}
	
	
	/// Sends the user back to the starting page on shake
	override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if (motion == .motionShake) {
			if self.currentVC.classForCoder != SignInPage.classForCoder(){
				let alert = UIAlertController(title: "Do you want to return to the sign in screen?", message: "You will be sent back to the starting screen, but not signed out.", preferredStyle: .alert)
				let signOut = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
					if let controller = self.storyboard?.instantiateViewController(withIdentifier: "signIn") as? SignInPage {
						controller.holding = self
						self.transition(from: self.currentVC, to: controller, with: .leftToRight)
					}
				})
				let cancel = UIAlertAction(title: "No", style: .cancel)
				alert.addAction(cancel)
				alert.addAction(signOut)
				DispatchQueue.main.async(execute: {self.present(alert, animated: true, completion: nil)})
			}
		}
	}
}

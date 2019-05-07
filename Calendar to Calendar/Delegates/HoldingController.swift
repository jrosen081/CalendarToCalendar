//
//  HoldingController.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 4/25/19.
//  Copyright © 2019 Jack Rosen. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn

protocol HoldingController: class {
	/// Transition from one view controller to another
	func transition(from: UIViewController, to: UIViewController, with transition: Transition)
	
	/// The current server
	var currentServer: CurrentServer {get set}
	
	/// The current interactor
	var currentInteractor: APIInteractor {get}
	
	/// The uiDelegate
	var uiDelegate: GIDSignInUIDelegate? {get set}
	
	/// The delegate for results
	var delegate: InteractionDelegate? {get set}
	
	/// The calendar holder
	var calendarHolder: CalendarHolder {get}
	
	/// Signs out the given account
	func signOut(from controller: UIViewController)
	
	/// Shows the add free dialogue
	func showAdFree()
}

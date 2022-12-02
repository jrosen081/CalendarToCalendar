//
//  CurrentServer.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 5/1/19.
//  Copyright © 2019 Jack Rosen. All rights reserved.
//

import Foundation

enum CurrentServer: String, Identifiable, CaseIterable {
	case GOOGLE = "Google"
	case OUTLOOK = "Outlook"
    
    var id: String { rawValue }
    
    var interactor: CalendarInteractor {
        switch self {
        case .GOOGLE:
            return GoogleInteractor.sharedInstance
        case .OUTLOOK:
            return OutlookInteractor.shared
        }
    }
}

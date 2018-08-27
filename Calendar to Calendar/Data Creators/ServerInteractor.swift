//
//  ServerInteractor.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 8/14/18.
//  Copyright © 2018 Jack Rosen. All rights reserved.
//

import Foundation

enum CurrentServer {
    case GOOGLE, OUTLOOK
}
final class ServerInteractor {
    static var currentServer = CurrentServer.GOOGLE
    static var current: APIInteractor {
        if ServerInteractor.currentServer == .GOOGLE {
            return GoogleInteractor.sharedInstance
        } else {
            return OutlookInteractor.sharedInstance
        }
    }
}

//
//  BackgroundSyncRequest.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 12/10/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import Foundation

struct BackgroundSyncRequest: Codable {
    let server: CurrentServer
    let id: String
    let name: String?
    let newName: String?
    let newAlarm: AlarmSetting
}

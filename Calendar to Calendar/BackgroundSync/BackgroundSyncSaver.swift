//
//  BackgroundSyncSaver.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 12/10/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import Foundation

private struct BackgroundSyncInformation: Codable {
    let requests: [BackgroundSyncRequest]
}

struct BackgroundSyncSaver {
    static let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathExtension("background_syncs.json")
    static func getTasks() async -> [BackgroundSyncRequest] {
        do {
            let data = try Data(contentsOf: fileURL)
            let syncInfo = try JSONDecoder().decode(BackgroundSyncInformation.self,
                                                    from: data)
            return syncInfo.requests
        } catch {
            print(error)
            return []
        }
    }
    
    static func saveTasks(tasks: [BackgroundSyncRequest]) throws {
        let requestData = BackgroundSyncInformation(requests: tasks)
        let data = try JSONEncoder().encode(requestData)
        try data.write(to: fileURL)
    }
}

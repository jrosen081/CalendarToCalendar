//
//  EnvironmentValues+Color.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/29/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    var backgroundColor: Color {
        (colorScheme == .dark ? Color.black : Color.white).opacity(0.8)
    }
}

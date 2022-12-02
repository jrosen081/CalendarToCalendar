//
//  BackgroundGradient.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/15/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import Foundation
import SwiftUI

private var gradientColors: [Color] {
    [
        Color(red: 22.0 / 255, green: 157 / 255, blue: 247 / 255)
    ]
}

extension LinearGradient {
    static var backgroundGradient: Self {
        Self.init(colors: gradientColors, startPoint: .top, endPoint: .bottom)
    }
}

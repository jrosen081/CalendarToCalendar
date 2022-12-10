//
//  ConfigurationRow.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/11/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import SwiftUI

struct ConfigurationRow<Content: View>: View {
    private let config: Content
    private let text: String

    init(_ text: String, @ViewBuilder config: () -> Content) {
        self.text = text
        self.config = config()
    }

    var body: some View {
        HStack {
            LabelHeader(text)
            Spacer()
            config
        }
    }
}

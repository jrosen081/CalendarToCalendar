//
//  ConfigurationView.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/11/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import SwiftUI

struct ConfigurationView<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            content
        }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 4).stroke())
            .padding(.top, 2)
            .transition(.scale(scale: 0, anchor: .top))
    }
}

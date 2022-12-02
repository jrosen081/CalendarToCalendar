//
//  Toggle.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/11/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import SwiftUI

struct Toggle: View {
    @Binding var isOn: Bool
    var body: some View {
        SwiftUI.Toggle("", isOn: $isOn)
            .labelsHidden()
    }
}

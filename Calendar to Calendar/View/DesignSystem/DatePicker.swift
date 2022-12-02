//
//  DatePicker.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/11/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import SwiftUI

struct DatePicker: View {
    @Binding var selection: Date
    var body: some View {
        SwiftUI.DatePicker("", selection: $selection)
            .labelsHidden()
    }
}

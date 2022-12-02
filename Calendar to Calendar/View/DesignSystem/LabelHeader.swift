//
//  LabelHeader.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/11/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import SwiftUI

func LabelHeader(_ string: String) -> some View {
    Text(string)
        .font(.body)
}

struct LabelHeader_Previews: PreviewProvider {
    static var previews: some View {
        LabelHeader("Hello")
    }
}

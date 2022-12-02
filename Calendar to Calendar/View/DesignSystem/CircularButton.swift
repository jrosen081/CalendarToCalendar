//
//  RoundedButton.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/11/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import SwiftUI

func CircularButton(action: @escaping () -> Void, label: () -> some View) -> some View {
    Button(action: action, label: {
        label()
            .padding(12)
            .overlay(Capsule().stroke())
            .contentShape(Rectangle())
    })
    .buttonStyle(CircularButtonStyle())
}

private struct CircularButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.2 : 1)
    }
}

struct RoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        CircularButton {
            
        } label: {
            Text("hi")
        }
        CircularButton {
            
        } label: {
            Label("HI", systemImage: "pencil")
        }
    }
}

//
//  OnboardingViews.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/29/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import EventKit
import SwiftUI

enum OnboardingStep {
    case welcome
    case signIn
    case requestingPermissions
    case finish
}

struct OnboardingViews: View {
    let dismiss: () -> Void
    @State private var onboardingStep: OnboardingStep = .welcome
    @State private var canPassSignInScreen = CurrentServer.allCases.contains(where: \.interactor.isSignedIn)
    @State private var calendarAccess: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
    var body: some View {
        switch onboardingStep {
        case .welcome:
            OnboardingView(title: "Welcome to Calendar to Calendar",
                           buttonText: "Continue",
                           buttonEnabled: true) {
                self.onboardingStep = .signIn
            } content: {
                VStack {
                    Text("""
    This app allows you to save your Google or Outlook Calendars into your phone calendar.

    Please continue with the setup, so you will be ready to use the app!

    """)

                    Spacer()
                }
                .padding(.top)
            }
        case .signIn:
            OnboardingView(title: "Sign in to your accounts",
                           buttonText: "Continue",
                           buttonEnabled: canPassSignInScreen) {
                if self.calendarAccess != .authorized {
                    self.onboardingStep = .requestingPermissions
                } else {
                    self.onboardingStep = .finish
                }

            } content: {
                LoginScreen(canLogOut: false) { _, _ in
                    self.canPassSignInScreen = true
                }
            }
        case .requestingPermissions:
            OnboardingView(title: "Allow Access to Calendar",
                           buttonText: "Grant Access",
                           buttonEnabled: true) {
                if [.denied, .restricted].contains(self.calendarAccess) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                } else {
                    Task {
                        defer {
                            self.calendarAccess = EKEventStore.authorizationStatus(for: .event)
                            if self.calendarAccess == .authorized {
                                DispatchQueue.main.async {
                                    self.onboardingStep = .finish
                                }
                            }
                        }
                        _ = try? await EKEventStore().requestAccess(to: .event)
                    }
                }
            } content: {
                VStack {
                    Text("This app needs calendar access to save your calendar events to your phone calendar!")
                        .font(.subheadline)
                    Spacer()
                }.padding(.top)
            }
        case .finish:
            OnboardingView(title: "Congratulations",
                           buttonText: "Done",
                           buttonEnabled: true,
                           nextClicked: dismiss) {
                VStack {
                    Text("Everything is set up. Enjoy using the app!")
                        .font(.subheadline)
                    Spacer()
                }.padding(.top)
            }
        }
    }
}

struct OnboardingView<Content: View>: View {
    let title: String
    let buttonText: String
    let buttonEnabled: Bool
    let nextClicked: () -> Void
    let content: () -> Content

    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            content()

            CircularButton(action: nextClicked) {
                Text(buttonText)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .foregroundColor(.green)
            .opacity(buttonEnabled ? 1 : 0.2)
            .disabled(!buttonEnabled)
        }.padding(.horizontal)
    }
}

struct OnboardingViews_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingViews { print("Bye") }
    }
}

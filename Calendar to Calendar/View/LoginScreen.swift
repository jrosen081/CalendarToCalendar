//
//  LoginScreen.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/11/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct LoginInformation: Identifiable {
    let id: CurrentServer
    var signedIn: Bool
}

struct LoginScreen: View {
    private static func currentLoginState() -> [LoginInformation] {
        CurrentServer.allCases.map { LoginInformation(id: $0, signedIn: $0.interactor.isSignedIn) }
    }

    var canLogOut: Bool = true
    @State private var loginInformation = Self.currentLoginState()
    @State private var isLoggingIn: Bool = false
    @State private var hasError: Bool = false
    @Environment(\.backgroundColor) var backgroundColor
    let onCalendarResponse: ((CurrentServer, [Calendar]?) -> Void)

    func login(server: Binding<LoginInformation>) {
        isLoggingIn = true
        if server.wrappedValue.signedIn {
            server.wrappedValue.id.interactor.signOut()
            server.wrappedValue.signedIn = false
            onCalendarResponse(server.wrappedValue.id, nil)
            isLoggingIn = false
        } else {
            Task {
                defer { isLoggingIn = false }
                do {
                    try await server.wrappedValue.id.interactor.signIn()
                    server.wrappedValue.signedIn = true
                    let calendars = try await server.wrappedValue.id.interactor.getCalendars()
                    await MainActor.run {
                        onCalendarResponse(server.wrappedValue.id, calendars)
                    }

                } catch {
                    await MainActor.run {
                        hasError = true
                    }
                }
            }
        }
    }

    var body: some View {
        ZStack {
            Form {
                ForEach($loginInformation) { $info in
                    ConfigurationRow(info.id.rawValue) {
                        if canLogOut || !info.signedIn {
                            if info.id == .GOOGLE && !info.signedIn {
                                GoogleSignInButton {
                                    login(server: $info)
                                }.frame(maxWidth: 125)
                            } else {
                                CircularButton {
                                    login(server: $info)
                                } label: {
                                    Text(info.signedIn ? "Sign Out" : "Sign In")
                                }
                            }

                        } else {
                            HStack {
                                Image(systemName: "checkmark")
                                Text("Signed In")
                            }.foregroundColor(.green)
                        }
                    }
                }
            }
            if isLoggingIn {
                backgroundColor
                ProgressView("Signing In")
            }
        }.alert(isPresented: $hasError) {
            Alert(title: Text("Something went wrong"), dismissButton: .default(Text("Ok")))
        }
        .onAppear {
            self.loginInformation = Self.currentLoginState()
        }
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen { _, _ in print("hi")}
    }
}

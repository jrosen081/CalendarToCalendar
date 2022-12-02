//
//  LoginScreen.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/11/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import SwiftUI
import GoogleSignIn

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
    let onCalendarResponse: ((CurrentServer, [Calendar]) -> Void)
    
    var body: some View {
        ZStack {
            Form {
                ForEach($loginInformation) { $info in
                    ConfigurationRow(info.id.rawValue) {
                        if canLogOut || !info.signedIn {
                            CircularButton {
                                isLoggingIn = true
                                if info.signedIn {
                                    info.id.interactor.signOut()
                                    info.signedIn = false
                                    isLoggingIn = false
                                } else {
                                    Task {
                                        defer { isLoggingIn = false }
                                        do {
                                            try await info.id.interactor.signIn()
                                            info.signedIn = true
                                            let calendars = try await info.id.interactor.getCalendars()
                                            await MainActor.run {
                                                onCalendarResponse(info.id, calendars)
                                            }
                                            
                                        } catch {
                                            await MainActor.run {
                                                hasError = true
                                            }
                                        }
                                        
                                    }
                                }
                            } label: {
                                Text(info.signedIn ? "Sign Out" : "Sign In")
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
        .background(SignInWrapper())
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

private class SignInController: UIViewController, GIDSignInUIDelegate {
    
}


struct SignInWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = SignInController(nibName: nil, bundle: nil)
        GIDSignIn.sharedInstance().uiDelegate = controller
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Do nothing
    }
}

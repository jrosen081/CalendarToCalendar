//
//  LoginView.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/1/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    enum AuthState {
        case unknown, notSignedIn
    }
    
    let interactor: CalendarInteractor
    @State private var authState: AuthState = .unknown
    @State private var showingNextScreen = false
    
    var body: some View {
        switch authState {
        case .unknown:
            ProgressView()
                .onAppear {
                    Task {
                        do {
                            try await interactor.restoreSignIn()
                            await setShowingNextScreen(true)
                            await MainActor.run {
                                authState = .notSignedIn
                            }
                        } catch {
                            await setShowingNextScreen(false)
                        }
                    }
                }
        case .notSignedIn:
            VStack {
                Text("Still in progress")
                Spacer()
                ViewControllerPresenting { controller in
                    Button("Sign In") {
                        Task {
                            do {
                                try await interactor.signIn(controller: controller)
                                await setShowingNextScreen(true)
                            } catch {
                                print("Something went wrong \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @MainActor
    private func setShowingNextScreen(_ isShowing: Bool) async {
        self.showingNextScreen = isShowing
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(interactor: MockCalendarInteractor())
    }
}

private struct ViewControllerPresenting<Content: View>: UIViewControllerRepresentable {
    let builder: (UIViewController) -> Content
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let hostingController = UIHostingController(rootView: builder(controller))
        controller.view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            controller.view.widthAnchor.constraint(equalTo: hostingController.view.widthAnchor, multiplier: 1),
            controller.view.heightAnchor.constraint(equalTo: hostingController.view.heightAnchor, multiplier: 1),
            controller.view.centerXAnchor.constraint(equalTo: hostingController.view.centerXAnchor),
            controller.view.centerYAnchor.constraint(equalTo: hostingController.view.centerYAnchor)
        ])
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Do nothing
    }
}

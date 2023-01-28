//
//  MainView.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/11/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import Foundation
import SwiftUI

enum LoadingState<T> {
    case loading
    case error
    case success(T)
}

enum Screen {
    case request
    case sync
    case signIn
}

struct MainView: View {
    @State private var calendarInfo: [CurrentServer: [Calendar]] = [:]
    @State private var currentScreen = Screen.request
    @State private var showingOnboarding = UserDefaults.standard.integer(forKey: "Version") < 3

    var body: some View {
        TabView(selection: $currentScreen) {
            NavigationView {
                ExportFlowLandingPage(calendars: $calendarInfo, goToSettings: {
                    currentScreen = .signIn
                })
            }
            .tag(Screen.request)
            .tabItem {
                Text("Export")
                Image(systemName: "calendar")
            }
            SyncView {
                currentScreen = .request
            }
            .tag(Screen.sync)
            .tabItem {
                Text("Sync")
                Image(systemName: "arrow.triangle.2.circlepath")
            }
            
            NavigationView {
                LoginScreen { server, calendars in
                    calendarInfo[server] = calendars
                }
                .navigationTitle("Accounts")
            }
            .tag(Screen.signIn)
            .tabItem {
                Text("Profile")
                Image(systemName: "person")
            }
        }.fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingViews {
                UserDefaults.standard.set(3, forKey: "Version")
                NotificationCenter.default.post(name: .onboardingFinished, object: nil)
                self.showingOnboarding = false
            }
        }
    }
}

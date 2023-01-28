//
//  SyncView.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 1/28/23.
//  Copyright © 2023 Jack Rosen. All rights reserved.
//

import Foundation
import SwiftUI
import Paywall

struct SyncView: View {
    @State private var isShowingPaywall = false
    let paywallDismissed: () -> Void
    
    var body: some View {
        Text("Hi")
            .fullScreenCover(isPresented: $isShowingPaywall, onDismiss: paywallDismissed) {
                PaywallView(reasons: [
                    "Easily Keep Your Calendars in Sync",
                    "Rename All Synced Events",
                    "Add Alarms For All Events"
                ], plans: [
                    PaywallPlan(id: "1", type: "Annual Plan", price: "$200/year"),
                    PaywallPlan(id: "2", type: "Monthly Plan", price: "$15/months")
                ], onUpgrade: { _ in })
            }
            .onAppear {
                isShowingPaywall = true
            }
    }
}

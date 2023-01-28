import XCTest
@testable import Paywall
import SnapshotTesting
import SwiftUI

final class PaywallTests: XCTestCase {
    let record = false
    func testScreen() {
        let view = PaywallView(reasons: [
            "Easily Keep Your Calendars in Sync",
            "Rename All Synced Events",
            "Add Alarms For All Events"
        ], plans: [
            PaywallPlan(id: "1", type: "Annual Plan", price: "$200/year"),
            PaywallPlan(id: "2", type: "Monthly Plan", price: "$15/months")
        ], onUpgrade: { _ in })
        let viewController = UIHostingController(rootView: view)
        assertSnapshot(matching: viewController,
                       as: .image(on: .iPhone13),
                       record: record)
    }
}

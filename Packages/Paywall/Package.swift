// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Paywall",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Paywall",
            targets: ["Paywall"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
                 exact: "1.11.0"),
        .package(path: "../DesignSystem")
    ],
    targets: [
        .target(
            name: "Paywall",
            dependencies: [
                "DesignSystem"
            ]),
        .testTarget(
            name: "PaywallTests",
            dependencies: [
                "Paywall",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]),
    ]
)

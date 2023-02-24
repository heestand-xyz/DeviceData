// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "DeviceData",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "DeviceData",
            targets: ["DeviceData"]),
    ],
    targets: [
        .target(
            name: "DeviceData",
            dependencies: []),
        .testTarget(
            name: "DeviceDataTests",
            dependencies: ["DeviceData"])
    ]
)

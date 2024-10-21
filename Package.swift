// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "DeviceData",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "DeviceData",
            targets: ["DeviceData"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.4"),
    ],
    targets: [
        .target(
            name: "DeviceData",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
            ]),
        .testTarget(
            name: "DeviceDataTests",
            dependencies: ["DeviceData"])
    ]
)

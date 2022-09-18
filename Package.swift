// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NativePartialSheet",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "NativePartialSheet",
            targets: ["NativePartialSheet"]),
    ],
    targets: [
        .target(
            name: "NativePartialSheet",
            dependencies: ["NativePartialSheetHelper"]
        ),
        .target(name: "NativePartialSheetHelper"),
    ]
)

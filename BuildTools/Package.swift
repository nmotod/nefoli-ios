// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "BuildTools",
    dependencies: [
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.50.4"),
    ],
    targets: [
        .target(name: "BuildTools", path: ""),
    ]
)

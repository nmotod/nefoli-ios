// swift-tools-version: 5.7

import PackageDescription

let commonDependenciesForTest: [Target.Dependency] = [
    .product(name: "Difference", package: "Difference"),
]

let package = Package(
    name: "Modules",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "Root",
            targets: ["Root"]
        ),
        .library(
            name: "SettingsUI.Previews",
            targets: ["SettingsUI"]
        ),
        .library(
            name: "Bookmarks.Previews",
            targets: ["Bookmarks"]
        ),
        .library(
            name: "TabManageUI.Previews",
            targets: ["TabManageUI"]
        ),
        .library(
            name: "Utils.Previews",
            targets: ["Utils"]
        ),
        .library(
            name: "Theme.Previews",
            targets: ["Theme"]
        ),
    ],
    dependencies: [
        // .package(url: "https://github.com/mischa-hildebrand/AlignedCollectionViewFlowLayout", revision: "49330ef67177dba5c9e1a3efdd0df93d83f12ee7"),
        // .package(url: "https://github.com/siteline/SwiftUI-Introspect.git", revision: "0.1.4"),
        //        .package(url: "https://github.com/realm/SwiftLint.git", revision: "0.50.3"),
        //        .package(url: "https://github.com/apple/swift-format", branch: "main"),

        .package(url: "https://github.com/SnapKit/SnapKit", revision: "5.6.0"),
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.0"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.33.0"),
        .package(url: "https://github.com/krzysztofzablocki/Difference.git", from: "1.0.2"),
    ],
    targets: [
        .target(
            name: "Root",
            dependencies: [
                // .product(name: "AlignedCollectionViewFlowLayout", package: "AlignedCollectionViewFlowLayout"),
                // .product(name: "SnapKit", package: "SnapKit"),
                // .product(name: "Introspect", package: "SwiftUI-Introspect"),
                .target(name: "Database"),
                .target(name: "TabBrowser"),
            ]
        ),
        .target(
            name: "Database",
            dependencies: [
                .product(name: "Realm", package: "realm-swift"),
                .product(name: "RealmSwift", package: "realm-swift"),
            ]
        ),
        .testTarget(
            name: "DatabaseTests",
            dependencies: [
                .target(name: "Database"),
            ] + commonDependenciesForTest
        ),
        .target(
            name: "TabBrowser",
            dependencies: [
                .product(name: "SnapKit", package: "SnapKit"),
                .target(name: "Database"),
                .target(name: "Theme"),
                .target(name: "Utils"),
                .target(name: "Bookmarks"),
                .target(name: "SettingsUI"),
                .target(name: "TabManageUI"),
                .target(name: "CommandSystem"),
            ]
        ),
        .testTarget(
            name: "TabBrowserTests",
            dependencies: [
                .target(name: "TabBrowser"),
            ] + commonDependenciesForTest
        ),
        .target(
            name: "Theme",
            exclude: [
                "swiftgen.yml",
            ],
            resources: [
                .process("Resources"),
            ],
            plugins: [
                .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin"),
            ]
        ),
        .target(
            name: "Utils",
            dependencies: [
                .product(name: "SnapKit", package: "SnapKit"),
                .target(name: "Theme"),
            ]
        ),
        .testTarget(
            name: "UtilsTests",
            dependencies: [
                .target(name: "Utils"),
            ]
        ),
        .target(
            name: "Bookmarks",
            dependencies: [
                .target(name: "Database"),
                .target(name: "Theme"),
            ]
        ),
        .testTarget(
            name: "BookmarksTests",
            dependencies: [
                .target(name: "Bookmarks"),
            ]
        ),
        .target(
            name: "SettingsUI",
            dependencies: [
                .target(name: "Database"),
                .target(name: "Theme"),
                .target(name: "Utils"),
                .target(name: "ContentBlocker"),
            ]
        ),
        .testTarget(
            name: "SettingsUITests",
            dependencies: [
                .target(name: "SettingsUI"),
            ]
        ),
        .target(
            name: "ContentBlocker",
            dependencies: [
                .target(name: "Database"),
            ]
        ),
        .testTarget(
            name: "ContentBlockerTests",
            dependencies: [
                .target(name: "ContentBlocker"),
            ]
        ),
        .target(
            name: "TabManageUI",
            dependencies: [
                .target(name: "Database"),
                .target(name: "Theme"),
            ]
        ),
        .target(
            name: "CommandSystem",
            dependencies: []
        ),
    ]
)

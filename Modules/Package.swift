// swift-tools-version: 5.7

import PackageDescription

var package = Package(
    name: "Modules",
    defaultLocalization: "en",
    platforms: [
        .iOS("17.0.0"),
    ],
    products: [
        .library(
            name: "AppEntryPoint",
            targets: ["AppEntryPoint"]
        ),
        // `products` will be added via defineModule()
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", revision: "5.6.0"),
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.33.0"),
        .package(url: "https://github.com/krzysztofzablocki/Difference.git", from: "1.0.2"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.16.0"),
    ]
    // `targets` will be added via defineModule()
)

enum ModuleCategory: String {
    case EntryPoints
    case Components
    case Features
    case Utils
}

defineModule(.EntryPoints, .target(
    name: "AppEntryPoint",
    dependencies: [
        // .product(name: "AlignedCollectionViewFlowLayout", package: "AlignedCollectionViewFlowLayout"),
        // .product(name: "SnapKit", package: "SnapKit"),
        // .product(name: "Introspect", package: "SwiftUI-Introspect"),
        .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
        .target(name: "Database"),
        .target(name: "TabBrowser"),
    ]
), tests: false)

defineModule(.Components, .target(
    name: "Database",
    dependencies: [
        .product(name: "Realm", package: "realm-swift"),
        .product(name: "RealmSwift", package: "realm-swift"),
    ]
))

defineModule(.Components, .target(
    name: "ThemeSystem",
    exclude: [
        "swiftgen.yml",
    ],
    resources: [
        .process("Resources"),
    ],
    plugins: [
        .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin"),
    ]
), tests: false, previews: true)

defineModule(.Features, .target(
    name: "TabBrowser",
    dependencies: [
        .product(name: "SnapKit", package: "SnapKit"),
        .target(name: "Database"),
        .target(name: "ThemeSystem"),
        .target(name: "Utils"),
        .target(name: "Bookmarks"),
        .target(name: "SettingsUI"),
        .target(name: "TabManageUI"),
        .target(name: "CommandSystem"),
    ]
), previews: true)

defineModule(.Features, .target(
    name: "Bookmarks",
    dependencies: [
        .target(name: "Database"),
        .target(name: "ThemeSystem"),
        .target(name: "Utils"),
    ]
), previews: true)

defineModule(.Features, .target(
    name: "SettingsUI",
    dependencies: [
        .target(name: "Database"),
        .target(name: "ThemeSystem"),
        .target(name: "Utils"),
        .target(name: "ContentBlocker"),
    ]
), previews: true)

defineModule(.Features, .target(
    name: "ContentBlocker",
    dependencies: [
        .target(name: "Database"),
    ]
))

defineModule(.Features, .target(
    name: "TabManageUI",
    dependencies: [
        .target(name: "Database"),
        .target(name: "ThemeSystem"),
    ]
), previews: true)

defineModule(.Utils, .target(
    name: "Utils",
    dependencies: [
        .product(name: "SnapKit", package: "SnapKit"),
        .target(name: "ThemeSystem"),
    ]
), previews: true)

defineModule(.Utils, .target(
    name: "CommandSystem",
    dependencies: []
), tests: false)

func defineModule(_ category: ModuleCategory, _ target: Target, tests: Bool = true, previews: Bool = false) {
    target.path = "\(category)/\(target.name)"

    package.targets.append(target)

    if tests {
        package.targets.append(.testTarget(
            name: "\(target.name)Tests",
            dependencies: [
                .target(name: target.name),
                .product(name: "Difference", package: "Difference"),
            ],
            path: "\(category)/\(target.name)Tests"
        ))
    }

    if previews {
        package.products.append(.library(
            name: target.name + ".Previews",
            targets: [target.name]
        ))
    }
}

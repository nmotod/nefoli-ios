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
            name: "NFLAppEntryPoint",
            targets: ["NFLAppEntryPoint"]
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

let noTests: (Target) -> Target? = { _ in nil }

defineModule(.EntryPoints, .target(
    name: "NFLAppEntryPoint",
    dependencies: [
        // .product(name: "AlignedCollectionViewFlowLayout", package: "AlignedCollectionViewFlowLayout"),
        // .product(name: "SnapKit", package: "SnapKit"),
        // .product(name: "Introspect", package: "SwiftUI-Introspect"),
        .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
        .target(name: "NFLDatabase"),
        .target(name: "NFLTabBrowser"),
    ]
), test: noTests)

defineModule(.Components, .target(
    name: "NFLDatabase",
    dependencies: [
        .product(name: "Realm", package: "realm-swift"),
        .product(name: "RealmSwift", package: "realm-swift"),
    ]
), test: { (target: Target) in
    target.resources = [.process("Resources")]
    return target
})

defineModule(.Components, .executableTarget(
    name: "NFLDatabase_v17",
    dependencies: [
        .product(name: "Realm", package: "realm-swift"),
        .product(name: "RealmSwift", package: "realm-swift"),
    ]
), test: noTests)

package.products.append(.executable(
    name: "db-fixture-gen-v17",
    targets: ["NFLDatabase_v17"]
))

defineModule(.Components, .target(
    name: "NFLThemeSystem",
    exclude: [
        "swiftgen.yml",
    ],
    resources: [
        .process("Resources"),
    ],
    plugins: [
        .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin"),
    ]
), test: noTests, previews: true)

defineModule(.Components, .target(
    name: "NFLBookmark",
    dependencies: [
        .target(name: "NFLDatabase"),
        .target(name: "NFLThemeSystem"),
        .target(name: "Utils"),
    ]
), previews: true)

defineModule(.Components, .target(
    name: "NFLSettings",
    dependencies: [
        .target(name: "NFLDatabase"),
        .target(name: "NFLThemeSystem"),
        .target(name: "Utils"),
        .target(name: "NFLContentBlocker"),
    ]
), previews: true)

defineModule(.Components, .target(
    name: "NFLContentBlocker",
    dependencies: [
        .target(name: "NFLDatabase"),
    ]
))

defineModule(.Components, .target(
    name: "NFLTabManager",
    dependencies: [
        .target(name: "NFLDatabase"),
        .target(name: "NFLThemeSystem"),
    ]
), previews: true)

defineModule(.Utils, .target(
    name: "Utils",
    dependencies: [
        .product(name: "SnapKit", package: "SnapKit"),
        .target(name: "NFLThemeSystem"),
    ]
), previews: true)

defineModule(.Utils, .target(
    name: "ActionSystem",
    dependencies: []
), test: noTests)

defineModule(.Utils, .target(
    name: "WebViewStickyInteraction",
    dependencies: [
        .product(name: "SnapKit", package: "SnapKit"),
    ]
), test: noTests)

defineModule(.Features, .target(
    name: "NFLTabBrowser",
    dependencies: [
        .product(name: "SnapKit", package: "SnapKit"),
        .target(name: "NFLDatabase"),
        .target(name: "NFLThemeSystem"),
        .target(name: "Utils"),
        .target(name: "NFLBookmark"),
        .target(name: "NFLSettings"),
        .target(name: "NFLTabManager"),
        .target(name: "ActionSystem"),
        .target(name: "WebViewStickyInteraction"),
    ]
), previews: true)

func defineModule(
    _ category: ModuleCategory,
    _ target: Target,
    test: ((Target) -> Target?)? = nil,
    previews: Bool = false
) {
    target.path = "Sources/\(category)/\(target.name)"

    package.targets.append(target)

//    if tests {
//        package.targets.append(.testTarget(
//            name: "\(target.name)Tests",
//            dependencies: [
//                .target(name: target.name),
//                .product(name: "Difference", package: "Difference"),
//            ] + testDependencies,
//            path: "\(category)Tests/\(target.name)Tests"
//        ))
//    }

    var testTarget: Target? = .testTarget(
        name: "\(target.name)Tests",
        dependencies: [
            .target(name: target.name),
            .product(name: "Difference", package: "Difference"),
        ],
        path: "Tests/\(category)/\(target.name)Tests"
    )

    if let test {
        testTarget = test(testTarget!)
    }

    if let testTarget {
        package.targets.append(testTarget)
    }

    if previews {
        package.products.append(.library(
            name: target.name + ".Previews",
            targets: [target.name]
        ))
    }
}

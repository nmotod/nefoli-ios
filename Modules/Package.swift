// swift-tools-version: 5.7

import PackageDescription

extension Target.Dependency {
    static let SnapKit: Target.Dependency = .product(name: "SnapKit", package: "SnapKit")
}

var generatedProducts: [Product] = []
var generatedTargets: [Target] = []

let baseTargets: [Target] = [
    .target(
        name: "AppEntryPoint",
        dependencies: [
            .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
            "Database",
            "TabBrowser",
        ]
    ).with(),

    .target(
        name: "Database",
        dependencies: [
            .product(name: "Realm", package: "realm-swift"),
            .product(name: "RealmSwift", package: "realm-swift"),
        ]
    ).with(
        testCustom: { t in
            t.resources = [.process("Resources")]
        }
    ),

    .executableTarget(
        name: "Database_v17",
        dependencies: [
            .product(name: "Realm", package: "realm-swift"),
            .product(name: "RealmSwift", package: "realm-swift"),
        ]
    ).with(),

    .target(
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
    ).with(
        preview: true
    ),

    .target(
        name: "Bookmark",
        dependencies: [
            "Database",
            "ThemeSystem",
            "Utils",
        ]
    ).with(
        test: true,
        preview: true
    ),

    .target(
        name: "Settings",
        dependencies: [
            "Database",
            "ThemeSystem",
            "Utils",
            "ContentBlocker",
        ]
    ).with(
        test: true,
        preview: true
    ),

    .target(
        name: "ContentBlocker",
        dependencies: [
            "Database",
        ]
    ).with(
        test: true
    ),

    .target(
        name: "MenuSheet",
        dependencies: [
            "ThemeSystem",
            "Utils",
        ]
    ).with(
        preview: true
    ),

    .target(
        name: "TabBrowserCore",
        dependencies: [
            .SnapKit,
            "Database",
            "ThemeSystem",
            "Utils",
            "Bookmark",
            "MenuSheet",
            "ActionSystem",
            "WebViewStickyInteraction",
            "ContentBlocker",
        ]
    ).with(
        test: true,
        preview: true
    ),

    .target(
        name: "TabManager",
        dependencies: [
            "TabBrowserCore",
        ]
    ).with(
        test: true,
        preview: true
    ),

    .target(
        name: "TabBrowser",
        dependencies: [
            "TabBrowserCore",
            "TabManager",
            "Settings",
        ]
    ).with(),

    .target(
        name: "Utils",
        dependencies: [
            .SnapKit,
        ]
    ).with(
        test: true,
        preview: true
    ),

    .target(
        name: "ActionSystem",
        dependencies: []
    ).with(),

    .target(
        name: "WebViewStickyInteraction",
        dependencies: [
            .SnapKit,
        ]
    ).with(),
]

let package = Package(
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
        .executable(
            name: "db-fixture-gen-v17",
            targets: ["Database_v17"]
        ),
    ] + generatedProducts,
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", revision: "5.6.0"),
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.33.0"),
        .package(url: "https://github.com/krzysztofzablocki/Difference.git", from: "1.0.2"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.16.0"),
    ],
    targets: baseTargets + generatedTargets
)

extension Target {
    func with(
        test: Bool = false,
        testCustom: ((inout Target) -> Void)? = nil,
        preview: Bool = false
    ) -> Self {
        if test || testCustom != nil {
            var testTarget = Target.testTarget(
                name: "\(name)Tests",
                dependencies: [
                    .target(name: name),
                    .product(name: "Difference", package: "Difference"),
                ]
            )

            if let testCustom {
                testCustom(&testTarget)
            }

            generatedTargets.append(testTarget)
        }

        if preview {
            generatedProducts.append(.library(
                name: name + ".Previews",
                targets: [name]
            ))
        }

        return self
    }
}

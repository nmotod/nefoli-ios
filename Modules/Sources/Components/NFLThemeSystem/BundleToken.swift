import Foundation

class BundleToken {
    // https://forums.swift.org/t/unable-to-find-bundle-in-package-target-tests-when-package-depends-on-another-package-containing-resources-accessed-via-bundle-module/43974/5
    static var bundle: Bundle = {
        let bundleName = "Modules_" + String(reflecting: BundleToken.self).split(separator: ".")[0]

        let candidates = [
            /* Bundle should be present here when the package is linked into an App. */
            Bundle.main.resourceURL,

            /* Bundle should be present here when the package is linked into a framework. */
            Bundle(for: BundleToken.self).resourceURL,

            /* For command-line tools. */
            Bundle.main.bundleURL,

            /* Bundle should be present here when running previews from a different package (this is the path to "…/Debug-iphonesimulator/"). */
            Bundle(for: BundleToken.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent(),
            Bundle(for: BundleToken.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent(),
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }

        fatalError("unable to find bundle")
    }()
}

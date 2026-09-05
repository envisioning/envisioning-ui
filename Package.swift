// swift-tools-version: 5.9
import PackageDescription

// Both apps now deploy to iOS 26 / macOS 15, but the shared layer needs nothing
// newer than iOS 17, so the floor stays low. A lower floor costs nothing here and
// keeps the package usable from anything else in the estate.
let package = Package(
    name: "EnvisioningUI",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "EnvisioningUI", targets: ["EnvisioningUI"])
    ],
    dependencies: [
        // The typeface lives in the repo that builds it. One .ttf in the estate.
        .package(url: "https://github.com/envisioning/envisioning-octa.git", exact: "0.1.1")
    ],
    targets: [
        .target(name: "EnvisioningUI", dependencies: [.product(name: "EnvisioningOcta", package: "envisioning-octa")]),
        .testTarget(name: "EnvisioningUITests", dependencies: ["EnvisioningUI"])
    ]
)

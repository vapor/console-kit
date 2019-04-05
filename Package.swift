// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "console-kit",
    products: [
        .library(name: "ConsoleKit", targets: ["ConsoleKit"]),
    ],
    dependencies: [ ],
    targets: [
        .target(name: "ConsoleKit", dependencies: []),
        .testTarget(name: "ConsoleKitTests", dependencies: ["ConsoleKit"]),
        // .target(name: "ConsoleKitExample", dependencies: ["ConsoleKit"]),
    ]
)

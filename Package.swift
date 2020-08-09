// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "console-kit",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "ConsoleKit", targets: ["ConsoleKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
    ],
    targets: [
        .target(name: "ConsoleKit", dependencies: [
            .product(name: "Logging", package: "swift-log"),
        ]),
        .testTarget(name: "ConsoleKitTests", dependencies: [
            .target(name: "ConsoleKit"),
        ]),
        .target(name: "ConsoleKitExample", dependencies: [
            .target(name: "ConsoleKit"),
        ]),
    ]
)

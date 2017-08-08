// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Console",
    products: [
        .library(name: "Console", targets: ["Console"]),
    ],
    dependencies: [
        // Core utilities
        .package(url: "https://github.com/vapor/core.git", .upToNextMajor(from: "2.1.2")),
    ],
    targets: [
        .target(name: "Console", dependencies: ["Core"]),
        .testTarget(name: "ConsoleTests", dependencies: ["Console"]),
    ]
)

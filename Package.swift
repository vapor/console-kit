// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Console",
    products: [
        .library(name: "Console", targets: ["Console"]),
        .library(name: "Command", targets: ["Command"]),
    ],
    dependencies: [
        // Core utilities
        .package(url: "https://github.com/vapor/core.git", .branch("beta")),
    ],
    targets: [
        .target(name: "Console", dependencies: ["Core"]),
        .testTarget(name: "ConsoleTests", dependencies: ["Console"]),
        .target(name: "Command", dependencies: ["Console"]),
        .testTarget(name: "CommandTests", dependencies: ["Command"]),
        .target(name: "ConsoleExample", dependencies: ["Console"]),
    ]
)

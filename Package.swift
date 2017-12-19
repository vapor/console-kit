// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Console",
    products: [
        .library(name: "Console", targets: ["Console"]),
        .library(name: "Command", targets: ["Command"]),
        .library(name: "Logging", targets: ["Logging"]),
    ],
    dependencies: [
        // Swift Promises, Futures, and Streams.
        .package(url: "https://github.com/vapor/async.git", .branch("beta")),

        // Core extensions, type-aliases, and functions that facilitate common tasks.
        .package(url: "https://github.com/vapor/core.git", .branch("beta")),

        // Service container and configuration system.
        .package(url: "https://github.com/vapor/service.git", .branch("beta")),
    ],
    targets: [
        .target(name: "Console", dependencies: ["Async", "Bits", "COperatingSystem", "Service"]),
        .target(name: "Command", dependencies: ["Console"]),
        .testTarget(name: "ConsoleTests", dependencies: ["Console"]),
        .testTarget(name: "CommandTests", dependencies: ["Command"]),
        .target(name: "Logging", dependencies: []),
    ]
)

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
        .package(url: "https://github.com/vapor/async.git", "1.0.0-beta.1"..<"1.0.0-beta.2"),

        // Core extensions, type-aliases, and functions that facilitate common tasks.
        .package(url: "https://github.com/vapor/core.git", "3.0.0-beta.1"..<"3.0.0-beta.2"),

        // Service container and configuration system.
        .package(url: "https://github.com/vapor/service.git", "1.0.0-beta.1"..<"1.0.0-beta.2"),
    ],
    targets: [
        .target(name: "Console", dependencies: ["Async", "Bits", "COperatingSystem", "Service"]),
        .target(name: "Command", dependencies: ["Console"]),
        .testTarget(name: "ConsoleTests", dependencies: ["Console"]),
        .testTarget(name: "CommandTests", dependencies: ["Command"]),
        .target(name: "Logging", dependencies: []),
    ]
)

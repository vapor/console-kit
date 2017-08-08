// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Console",
    products: [
        .library(name: "Consoles", targets: ["Consoles"]),
        .library(name: "Commands", targets: ["Commands"]),
    ],
    dependencies: [
        // Core utilities
        .package(url: "https://github.com/vapor/core.git", .upToNextMajor(from: "2.1.2")),
    ],
    targets: [
        .target(name: "Consoles", dependencies: ["Core"]),
        .testTarget(name: "ConsolesTests", dependencies: ["Consoles"]),
        .target(name: "Commands", dependencies: ["Consoles"]),
        .testTarget(name: "CommandsTests", dependencies: ["Commands"]),
        .target(name: "ConsoleExample", dependencies: ["Consoles"]),
    ]
)

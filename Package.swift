// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "console",
    products: [
        .library(name: "Console", targets: ["Console"]),
        .library(name: "Command", targets: ["Command"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", .branch("master")),
    ],
    targets: [
        .target(name: "Console", dependencies: ["NIO"]),
        .target(name: "Command", dependencies: ["Console", "NIO"]),
        .testTarget(name: "ConsoleTests", dependencies: ["Console"]),
        .testTarget(name: "CommandTests", dependencies: ["Command"]),
        .target(name: "ConsoleDevelopment", dependencies: ["Command", "Console"]),
    ]
)

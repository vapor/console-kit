// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "console-kit",
    products: [
        .library(name: "ConsoleKit", targets: ["ConsoleKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", .branch("master")),
    ],
    targets: [
        .target(name: "ConsoleKit", dependencies: ["NIO"]),
        .testTarget(name: "ConsoleKitTests", dependencies: ["ConsoleKit"]),
        .target(name: "ConsoleKitExample", dependencies: ["ConsoleKit"]),
    ]
)

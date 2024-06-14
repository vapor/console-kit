// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "console-kit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(name: "ConsoleKit", targets: ["ConsoleKit"]),
        .library(name: "ConsoleKitTerminal", targets: ["ConsoleKitTerminal"]),
        .library(name: "ConsoleKitCommands", targets: ["ConsoleKitCommands"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.62.0"),
    ],
    targets: [
        .target(
            name: "ConsoleKit",
            dependencies: [
                .target(name: "ConsoleKitCommands"),
                .target(name: "ConsoleKitTerminal"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ConsoleKitCommands",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
                .target(name: "ConsoleKitTerminal"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ConsoleKitTerminal",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "ConsoleKitTests",
            dependencies: [.target(name: "ConsoleKit")],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "AsyncConsoleKitTests",
            dependencies: [.target(name: "ConsoleKit")],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "ConsoleKitPerformanceTests",
            dependencies: [.target(name: "ConsoleKit")],
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "ConsoleKitExample",
            dependencies: [.target(name: "ConsoleKit")],
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "ConsoleKitAsyncExample",
            dependencies: [.target(name: "ConsoleKit")],
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "ConsoleLoggerExample",
            dependencies: [
                .target(name: "ConsoleKit"),
                .product(name: "Logging", package: "swift-log"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ForwardTrailingClosures"),
    .enableUpcomingFeature("ConciseMagicFile"),
] }

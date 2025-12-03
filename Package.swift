// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "console-kit",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .watchOS(.v11),
        .tvOS(.v18),
    ],
    products: [
        .library(name: "ConsoleKit", targets: ["ConsoleKit"]),
        .library(name: "ConsoleLogger", targets: ["ConsoleLogger"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.3"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.4"),
        .package(url: "https://github.com/apple/swift-configuration", exact: "1.0.0-alpha.1"),
    ],
    targets: [
        .target(
            name: "ConsoleKit",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "ConsoleKitTests",
            dependencies: [
                .target(name: "ConsoleKit")
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ConsoleLogger",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Configuration", package: "swift-configuration"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "ConsoleLoggerTests",
            dependencies: [
                .target(name: "ConsoleLogger"),
                .product(name: "Configuration", package: "swift-configuration"),
            ],
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "ConsoleLoggerExample",
            dependencies: [
                .target(name: "ConsoleLogger"),
                .product(name: "Logging", package: "swift-log"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("ImmutableWeakCaptures"),
    ]
}

// swift-tools-version:6.1
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
        .library(name: "ConsoleKit", targets: ["ConsoleKit"])
    ],
    traits: [
        "ConsoleLogger",
        .default(enabledTraits: ["ConsoleLogger"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.3"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.4"),
    ],
    targets: [
        .target(
            name: "ConsoleKit",
            dependencies: [
                .product(name: "Logging", package: "swift-log", condition: .when(traits: ["ConsoleLogger"])),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "ConsoleKitTests",
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

var swiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("InternalImportsByDefault"),
    ]
}

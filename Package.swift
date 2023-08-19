// swift-tools-version:5.6
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
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3"),
    ],
    targets: [
        .target(name: "ConsoleKit", dependencies: [
            .product(name: "Logging", package: "swift-log"),
        ]),
        .testTarget(name: "ConsoleKitTests", dependencies: [
            .target(name: "ConsoleKit"),
        ]),
        .testTarget(name: "AsyncConsoleKitTests", dependencies: [
            .target(name: "ConsoleKit"),
        ]),
        .executableTarget(name: "ConsoleKitExample", dependencies: [
            .target(name: "ConsoleKit"),
        ]),
        .target(name: "ConsoleKitAsyncExample", dependencies: [
            .target(name: "ConsoleKit")
        ])
    ]
)

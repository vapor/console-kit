// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "benchmarks",
    platforms: [
        .macOS(.v15)
    ],
    dependencies: [
        .package(path: "../"),
        .package(url: "https://github.com/ordo-one/package-benchmark.git", from: "1.29.3"),
    ],
    targets: [
        .executableTarget(
            name: "ConsoleLogger",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
                .product(name: "ConsoleKit", package: "console-kit"),
            ],
            path: "ConsoleLogger",
            swiftSettings: swiftSettings,
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
            ]
        )
    ]
)

var swiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
}

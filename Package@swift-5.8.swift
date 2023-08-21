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
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-log.git", from: "1.5.3"),
		.package(url: "https://github.com/apple/swift-atomics.git", from: "1.1.0")
	],
	targets: [
		.target(name: "ConsoleKit", dependencies: [
			.product(name: "Logging", package: "swift-log"),
			.product(name: "Atomics", package: "swift-atomics")
		], swiftSettings: [.enableExperimentalFeature("StrictConcurrency=complete")]),
		.testTarget(name: "ConsoleKitTests", dependencies: [
			.target(name: "ConsoleKit"),
		], swiftSettings: [.enableExperimentalFeature("StrictConcurrency=complete")]),
		.testTarget(name: "AsyncConsoleKitTests", dependencies: [
			.target(name: "ConsoleKit"),
		], swiftSettings: [.enableExperimentalFeature("StrictConcurrency=complete")]),
		.testTarget(name: "ConsoleKitPerformanceTests", dependencies: [
			.target(name: "ConsoleKit")
		], swiftSettings: [.enableExperimentalFeature("StrictConcurrency=complete")]),
		.executableTarget(name: "ConsoleKitExample", dependencies: [
			.target(name: "ConsoleKit"),
		], swiftSettings: [.enableExperimentalFeature("StrictConcurrency=complete")]),
		.executableTarget(name: "ConsoleKitAsyncExample", dependencies: [
			.target(name: "ConsoleKit")
		], swiftSettings: [.enableExperimentalFeature("StrictConcurrency=complete")])
	]
)

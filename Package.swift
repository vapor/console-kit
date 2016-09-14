import PackageDescription

let package = Package(
    name: "Console",
    targets: [
        Target(name: "Console"),
        // Target(name: "ConsoleExample", dependencies: ["Console"])
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/polymorphic.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/core.git", majorVersion: 1),
    ],
    exclude: [
        "Sources/ConsoleExample"
    ]
)

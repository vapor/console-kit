import PackageDescription

let package = Package(
    name: "Console",
    targets: [
        Target(name: "Console"),
        // Target(name: "ConsoleExample", dependencies: ["Console"])
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/core.git", Version(2,0,0, prereleaseIdentifiers: ["beta"])),
    ],
    exclude: [
        "Sources/ConsoleExample"
    ]
)

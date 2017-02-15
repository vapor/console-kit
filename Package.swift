import PackageDescription

let package = Package(
    name: "Console",
    targets: [
        Target(name: "Console"),
        // Target(name: "ConsoleExample", dependencies: ["Console"])
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/polymorphic.git", Version(2,0,0, prereleaseIdentifiers: ["alpha"])),
        .Package(url: "https://github.com/vapor/core.git", Version(2,0,0, prereleaseIdentifiers: ["alpha"])),
    ],
    exclude: [
        "Sources/ConsoleExample"
    ]
)

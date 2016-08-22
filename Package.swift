import PackageDescription

let package = Package(
    name: "Console",
    targets: [
        Target(name: "Console"),
        Target(name: "ConsoleExample", dependencies: ["Console"])
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/polymorphic.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/vapor/core.git", majorVersion: 0, minor: 4),
    ]
)

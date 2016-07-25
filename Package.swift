import PackageDescription

let package = Package(
    name: "Console",
    targets: [
        Target(name: "Console"),
        Target(name: "ConsoleExample", dependencies: ["Console"])
    ],
    dependencies: [
        .Package(url: "https://github.com/ketzusaka/Strand.git", majorVersion: 1, minor: 6),
        .Package(url: "https://github.com/qutheory/polymorphic.git", majorVersion: 0, minor: 3),
        .Package(url: "https://github.com/qutheory/core.git", majorVersion: 0, minor: 2),
    ]
)

import PackageDescription

let package = Package(
    name: "Console",
    dependencies: [
        .Package(url: "https://github.com/ketzusaka/Strand.git", majorVersion: 1, minor: 5),
        .Package(url: "https://github.com/qutheory/polymorphic.git", majorVersion: 0, minor: 2),
        .Package(url: "https://github.com/qutheory/libc.git", majorVersion: 0, minor: 1),
    ],
    targets: [
        Target(name: "Console"),
        Target(name: "ConsoleExample", dependencies: ["Console"])
    ]
)

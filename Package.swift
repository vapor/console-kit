import PackageDescription

let package = Package(
    name: "Console",
    dependencies: [
        .Package(url: "https://github.com/ketzusaka/Strand.git", majorVersion: 1, minor: 4)
    ],
    targets: [
        Target(name: "Console"),
        Target(name: "ConsoleExample", dependencies: ["Console"])
    ]
)

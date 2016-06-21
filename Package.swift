import PackageDescription

let package = Package(
    name: "Console",
    dependencies: [
        .Package(url: "https://github.com/ketzusaka/Strand.git", majorVersion: 1, minor: 4)
    ]
)

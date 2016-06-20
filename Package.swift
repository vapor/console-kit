import PackageDescription

let package = Package(
    name: "MySQL",
    dependencies: [
        .Package(url: "https://github.com/qutheory/cmysql.git", majorVersion: 0, minor: 2),
        .Package(url: "https://github.com/qutheory/libc.git", majorVersion: 0, minor: 1),
    ]
)

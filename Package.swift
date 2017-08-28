// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Ice",
    products: [
        .executable(name: "ice", targets: ["CLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/jakeheis/SwiftCLI", .upToNextMinor(from: "3.0.1")),
        .package(url: "https://github.com/JustHTTP/Just", .upToNextMinor(from: "0.6.0"))
    ],
    targets: [
        .target(name: "CLI", dependencies: ["SwiftCLI", "Core"]),
        .target(name: "Core", dependencies: ["Just"]),
    ]
)

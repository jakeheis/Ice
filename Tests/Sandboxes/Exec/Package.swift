// swift-tools-version:4.0
// Managed by ice

import PackageDescription

let package = Package(
    name: "Exec",
    dependencies: [
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "3.0.3"),
    ],
    targets: [
        .target(name: "Exec", dependencies: ["SwiftCLI"]),
    ]
)

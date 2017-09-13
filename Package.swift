// swift-tools-version:4.0
// Managed by ice

import PackageDescription

let package = Package(
    name: "Ice",
    products: [
        .executable(name: "ice", targets: ["CLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jakeheis/FileKit", from: "4.1.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "2.1.0"),
        .package(url: "https://github.com/sharplet/Regex", from: "1.1.0"),
        .package(url: "https://github.com/jakeheis/SwiftCLI", .branchItem("master")),
    ],
    targets: [
        .target(name: "CLI", dependencies: ["Core", "FileKit", "SwiftCLI"]),
        .target(name: "Core", dependencies: ["Exec", "FileKit", "Rainbow", "Regex", "Transformers"]),
        .target(name: "Exec", dependencies: ["Regex", "SwiftCLI"]),
        .target(name: "Transformers", dependencies: ["Exec", "Rainbow", "Regex"]),
        .testTarget(name: "CoreTests", dependencies: ["Core"]),
    ]
)

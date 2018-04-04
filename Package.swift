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
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.1.1"),
        .package(url: "https://github.com/sharplet/Regex", from: "1.1.0"),
        .package(url: "https://github.com/jakeheis/SwiftCLI", .branchItem("task")),
        .package(url: "https://github.com/scottrhoyt/SwiftyTextTable", from: "0.8.0"),
    ],
    targets: [
        .target(name: "CLI", dependencies: ["Core", "FileKit", "SwiftCLI", "SwiftyTextTable"]),
        .target(name: "Core", dependencies: ["Exec", "FileKit", "Rainbow", "Regex", "Transformers"]),
        .target(name: "Exec", dependencies: ["Rainbow", "Regex", "SwiftCLI"]),
        .target(name: "Transformers", dependencies: ["Exec", "Rainbow", "Regex", "SwiftCLI"]),
        .testTarget(name: "CLITests", dependencies: ["Rainbow"]),
        .testTarget(name: "CoreTests", dependencies: ["Core"]),
        .testTarget(name: "TransformersTests", dependencies: ["Exec", "Transformers"]),
    ]
)

// swift-tools-version:4.0
// Managed by ice

import PackageDescription

let package = Package(
    name: "Ice",
    products: [
        .executable(name: "ice", targets: ["CLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "1.11.0"),
        .package(url: "https://github.com/JustHTTP/Just", from: "0.6.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "2.1.0"),
        .package(url: "https://github.com/sharplet/Regex", from: "1.1.0"),
        .package(url: "https://github.com/jakeheis/SwiftCLI", .branchItem("master")),
    ],
    targets: [
        .target(name: "CLI", dependencies: ["Core", "SwiftCLI"]),
        .target(name: "Core", dependencies: ["Exec", "Files", "Just", "Rainbow", "Regex"]),
        .target(name: "Exec", dependencies: ["Regex", "SwiftCLI"]),
        .testTarget(name: "CoreTests", dependencies: ["Core"]),
    ]
)

// swift-tools-version:3.1

import PackageDescription

let package = Package(name: "Ice")

package.dependencies = [
    .Package(url: "https://github.com/jakeheis/SwiftCLI", majorVersion: 3, minor: 0),
    .Package(url: "https://github.com/JohnSundell/Files", majorVersion: 1, minor: 10)
]

//
//  PackageLoader.swift
//  IceKit
//
//  Created by Jake Heiser on 7/28/18.
//

import Foundation
import PathKit
import SwiftCLI

public struct PackageFile {
    
    private final class ToolsVersionLine: Matcher, Matchable {
        // Spec at: https://github.com/apple/swift-package-manager/blob/master/Sources/PackageLoading/ToolsVersionLoader.swift#L97
        static let regex = Regex("^// swift-tools-version:(.*?)(?:;.*|$)", options: [.caseInsensitive])
        
        var toolsVersion: String { return captures[0] }
    }
    
    public static func formPackagePath(in directory: Path, versionTag: String?) -> Path {
        var file = "Package"
        if let toolsVersion = versionTag {
            file += "@swift-\(toolsVersion)"
        }
        file += ".swift"
        return directory + file
    }
    
    public static func find(in directory: Path) -> PackageFile? {
        guard let compilerVersion = SPM(directory: directory).version else {
            return nil
        }
        
        var current = directory
        while true {
            let path = PackageFile.formPackagePath(in: current, versionTag: nil)
            if path.exists {
                return PackageFile(directory: current, compilerVersion: compilerVersion)
            }
            let parent = current.parent()
            if current == parent { // Root; can't go up any farther, no Package.swift
                return nil
            }
            current = parent
        }
    }
    
    public let path: Path
    public let toolsVersion: SwiftToolsVersion
    
    public var content: String {
        return (try? path.read()) ?? ""
    }
    
    public init?(directory: Path, compilerVersion: SwiftToolsVersion) {
        let nonSpecific = PackageFile.formPackagePath(in: directory, versionTag: nil)
        
        guard nonSpecific.exists else {
            return nil
        }
        
        let version = compilerVersion.version
        let tags = [
            "\(version.major).\(version.minor).\(version.patch)",
            "\(version.major).\(version.minor)",
            "\(version.major)",
        ]
        
        if let taggedPath = tags.lazy.map({ PackageFile.formPackagePath(in: directory, versionTag: $0) }).first(where: { $0.exists }) {
            self.init(path: taggedPath)
        } else {
            self.init(path: nonSpecific)
        }
    }
    
    public init?(path: Path) {
        self.path = path
        
        guard let readStream = ReadStream.for(path: path.string),
            let line = readStream.readLine(),
            let match = ToolsVersionLine.findMatch(in: line),
            let toolsVersion = SwiftToolsVersion(match.toolsVersion) else {
                return nil
        }
        self.toolsVersion = toolsVersion
    }
    
    public func load(with config: Config?) throws -> Package {
        let json = try SPM(directory: path.parent()).dumpPackage(mode: .model)
        
        let data: ModernPackageData
        if let v5_0 = try? JSONDecoder().decode(PackageDataV5_0.self, from: json) {
            Logger.verbose <<< "Parsing package output as from SPM v5.0"
            data = v5_0
        } else if let v4_2 = try? JSONDecoder().decode(PackageDataV4_2.self, from: json) {
            Logger.verbose <<< "Parsing package output as from SPM v4.2"
            data = v4_2.convertToModern()
        } else if let v4_0 = try? JSONDecoder().decode(PackageDataV4_0.self, from: json) {
            Logger.verbose <<< "Parsing package output as from SPM v4.0"
            data = v4_0.convertToModern()
        } else {
            throw IceError(message: "can't parse Package.swift")
        }
        return Package(data: data, toolsVersion: toolsVersion, path: path, config: config)
    }
    
}

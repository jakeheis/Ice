//
//  PackageLoader.swift
//  IceKit
//
//  Created by Jake Heiser on 7/28/18.
//

import Foundation
import PathKit
import Regex
import SwiftCLI

struct PackageLoader {
    
    private final class ToolsVersionLine: Matcher, Matchable {
        // Spec at: https://github.com/apple/swift-package-manager/blob/master/Sources/PackageLoading/ToolsVersionLoader.swift#L97
        static let regex = Regex("^// swift-tools-version:(.*?)(?:;.*|$)", options: [.ignoreCase])
        
        var toolsVersion: String { return captures[0] }
    }
    
    static func load(directory: Path, config: Config?) throws -> Package {
        let data = try SPM(directory: directory).dumpPackage()
        
        guard let file = ReadStream.for(path: (directory + Package.fileName).string),
            let line = file.readLine(),
            let match = ToolsVersionLine.findMatch(in: line),
            let toolsVersion = SwiftToolsVersion(match.toolsVersion) else {
                throw IceError(message: "couldn't read Package.swift")
        }
        
        return try load(from: data, toolsVersion: toolsVersion, directory: directory, config: config)
    }
    
    static func load(from payload: Data, toolsVersion: SwiftToolsVersion, directory: Path, config: Config?) throws -> Package {
        let data: ModernPackageData
        if let v4_2 = try? JSONDecoder().decode(PackageDataV4_2.self, from: payload) {
            data = v4_2
        } else if let v4_0 = try? JSONDecoder().decode(PackageDataV4_0.self, from: payload) {
            data = v4_0.convertToModern()
        } else {
            throw IceError(message: "can't parse Package.swift")
        }
        return Package(data: data, toolsVersion: toolsVersion, directory: directory, config: config)
    }
    
    private init() {}

}

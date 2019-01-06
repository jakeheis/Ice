//
//  Description_v5.swift
//  Ice
//
//  Created by Jake Heiser on 1/3/19.
//

import Foundation

public enum PlatformName: String, Codable, Equatable {
    case macos
    case ios
    case tvos
    case watchos
    case linux
    
    var functionName: String {
        // macos -> macOS
        return rawValue.replacingOccurrences(of: "os", with: "OS")
    }
}

public struct PackageDescriptionDump: Decodable {
    public let package: PackageDescription
}

public struct PackageDescription: Decodable {
    
    public struct Platforms: Decodable {
        public struct PlatformValue: Decodable {
            public struct PlatformNameContainer: Decodable {
                let name: PlatformName
            }
            public struct Version: Decodable {
                let value: String
            }
            public let platform: PlatformNameContainer
            public let version: Version
        }
        
        public let value: [PlatformValue]
    }
    
    public let platforms: Platforms
    
}

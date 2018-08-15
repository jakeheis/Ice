//
//  Resolved.swift
//  Core
//
//  Created by Jake Heiser on 3/8/18.
//

import Foundation
import PathKit

public struct Resolved: Decodable {
    
    public struct Object: Decodable {
        public struct Pin: Decodable {
            public struct State: Decodable {
                public let branch: String?
                public let revision: String
                public let version: String?
            }
            public let package: String
            public let repositoryURL: String
            public let state: State
        }
        public let pins: [Pin]
    }
    
    public static let filePath = Path("Package.resolved")
    
    public let object: Object
    public var pins: [Object.Pin] {
        return object.pins
    }
    
    public static func load(in directory: Path) throws -> Resolved {
        guard let file = load(from: directory + filePath) else {
            throw IceError(message: "can't parse Package.resolved")
        }
        return file
    }
    
    public func findPin(url: String) -> Object.Pin? {
        return pins.first(where: { $0.repositoryURL == url })
    }
    
}

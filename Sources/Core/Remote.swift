
//
//  Remote.swift
//  Ice
//
//  Created by Jake Heiser on 7/21/17.
//

import Foundation
import Just

public struct RepositoryReference {
    
    public let owner: String
    public let name: String
    
    public var url: String {
        return "https://github.com/\(owner)/\(name)"
    }
    
    public var combined: String {
        return "\(owner)/\(name)"
    }
    
    public init?(_ combined: String) {
        let components = combined.components(separatedBy: "/")
        guard components.count == 2 else {
            return nil
        }
        self.owner = components[0]
        self.name = components[1]
    }
    
}

public struct RepositoryTag: Decodable {
    let name: String
}

public struct Remote {
    
    public static func latestVersion(of ref: RepositoryReference) -> Version? {
        if let data = Just.get("https://api.github.com/repos/\(ref.combined)/tags").content,
            let tags = try? JSONDecoder().decode([RepositoryTag].self, from: data) {
            let versions = tags.flatMap { Version.init($0.name) }.sorted()
            if let mostRecent = versions.last {
                return mostRecent
            }
        }
        return nil
    }

}

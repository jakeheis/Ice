
//
//  Remote.swift
//  Ice
//
//  Created by Jake Heiser on 7/21/17.
//

import Foundation
import Just

// import Files

public struct RepositoryTag: Decodable {
    let name: String
}

public struct Remote {
    
    public static func latestVersion(of package: String) -> Version? {
        if let data = Just.get("https://api.github.com/repos/\(package)/tags").content,
            let tags = try? JSONDecoder().decode([RepositoryTag].self, from: data) {
            let versions = tags.flatMap { Version.init($0.name) }.sorted()
            if let mostRecent = versions.last {
                return mostRecent
            }
        }
        return nil
    }

}

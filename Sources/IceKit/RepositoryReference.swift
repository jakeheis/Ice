
//
//  RepositoryReference.swift
//  Ice
//
//  Created by Jake Heiser on 7/21/17.
//

import Regex

public struct RepositoryReference {
    
    public let url: String
    public var name: String {
        let trimmed = url.hasSuffix(".git") ? String(url[..<url.index(url.endIndex, offsetBy: -4)]) : url
        return trimmed.components(separatedBy: "/").last!
    }
    
    public init?(blob: String, registry: RegistryType? = nil) {
        if Regex("^[a-zA-Z\\-]+/[a-zA-Z\\-]+$").matches(blob) {
            self.init(url: "https://github.com/\(blob)")
        } else if let match = Regex("^(gh|gl):([a-zA-Z\\-]+/[a-zA-Z\\-]+)$").firstMatch(in: blob)  {
            let path = match.captures[1]!
            let url: String
            if match.captures[0] == "gh" {
                url = "https://github.com/\(path)"
            } else {
                url = "https://gitlab.com/\(path)"
            }
            self.init(url: url)
        } else if Regex("^[a-zA-Z\\-]+$").matches(blob), let registry = registry {
            if let entry = registry.get(blob) {
                self.init(url: entry.url)
            } else {
                return nil
            }
        } else {
            self.init(url: blob)
        }
    }
    
    public init(url: String) {
        self.url = url
    }
    
    public func retrieveVersions() throws -> [Version] {
        return try Git.lsRemote(url: url).sorted()
    }
    
    public func latestVersion() throws -> Version? {
        return try retrieveVersions().last
    }
    
}

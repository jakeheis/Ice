
//
//  RepositoryReference.swift
//  Ice
//
//  Created by Jake Heiser on 7/21/17.
//

import Foundation
import Just
import Regex

public struct RepositoryReference {
    
    public let url: String
    public var name: String {
        let trimmed = url.hasSuffix(".git") ? String(url[..<url.index(url.endIndex, offsetBy: -4)]) : url
        return trimmed.components(separatedBy: "/").last!
    }
    
    public init?(_ blob: String) {
        if Regex("^[a-zA-Z]+/[a-zA-Z]+$").matches(blob) {
            self.init(url: "https://github.com/\(blob)")
        } else if Regex("^(gh|gl):[a-zA-Z]+/[a-zA-Z]+$").matches(blob)  {
            let path = blob[blob.index(blob.startIndex, offsetBy: 3)...]
            let url: String
            if blob.hasPrefix("gh:") {
                url = "https://github.com/\(path)"
            } else {
                url = "https://gitlab.com/\(path)"
            }
            self.init(url: url)
        } else if !Regex("^[a-zA-Z]+$").matches(blob) {
            self.init(url: blob)
        } else {
            return nil
        }
    }
    
    public init(url: String) {
        self.url = url
    }
    
    public func latestVersion() throws -> Version? {
        let tagOutput: String
        do {
            tagOutput = try Git.lsRemote(url: url)
        } catch let error as IceError {
            throw IceError(message: "not a valid package reference", exitStatus: error.exitStatus)
        }
        let tags = tagOutput.components(separatedBy: "\n").flatMap { (line) in
            guard let index = line.index(of: "\t") else {
                return nil
            }
            return String(line[line.index(index, offsetBy: "refs/tags/".characters.count + 1)...])
        }
        return tags.flatMap { Version($0) }.sorted().last
    }
    
}

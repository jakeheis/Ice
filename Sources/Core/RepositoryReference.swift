
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
    
    public let name: String
    public let url: String
    
    public init?(_ blob: String) {
        if Regex("^[a-zA-Z]+/[a-zA-Z]+$").matches(blob) {
            self.init(name: blob.components(separatedBy: "/")[1], url: "https://github.com/\(blob)")
        } else if Regex("^(gh|gl):[a-zA-Z]+/[a-zA-Z]+$").matches(blob)  {
            let path = blob[blob.index(blob.startIndex, offsetBy: 3)...]
            let url: String
            if blob.hasPrefix("gh:") {
                url = "https://github.com/\(path)"
            } else {
                url = "https://gitlab.com/\(path)"
            }
            self.init(name: blob.components(separatedBy: "/")[1], url: url)
        } else {
            let trimmed = blob.hasSuffix(".git") ? String(blob[..<blob.index(blob.endIndex, offsetBy: -4)]) : blob
            let name = trimmed.components(separatedBy: "/").last!
            self.init(name: name, url: blob)
        }
    }
    
    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
    
    public func latestVersion() -> Version? {
        let output = Pipe()
        
        let clone = Process()
        clone.launchPath = "/usr/bin/env"
        clone.arguments = ["git", "ls-remote", "--tags", url]
        clone.standardOutput = output
        clone.launch()
        clone.waitUntilExit()
        
        guard let tagOutput = String(data: output.fileHandleForReading.availableData, encoding: .utf8) else {
            return nil
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

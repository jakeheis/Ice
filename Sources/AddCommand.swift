//
//  AddCommand.swift
//  Bark
//
//  Created by Jake Heiser on 7/21/17.
//

import Foundation
import SwiftCLI

struct RepositoryTag: Decodable {
    let name: String
}

class AddCommand: Command {
    
    let name = "add"
    let dependency = Parameter()
    
    func execute() throws {
        let dependency = self.dependency.value
        
        let package = try Package()
        
        let fullUrl = "https://github.com/\(dependency)"
        if package.dependencies.contains(where: { $0.url == fullUrl }) {
            print("Dependency already exists")
            throw SPM.Error.processFailed
        }
        
        var major: Int?
        var minor: Int?
        
        if let tagUrl = URL(string: "https://api.github.com/repos/\(dependency)/tags") {
            let (data, _, _) = URLSession.synchronousDataTask(with: tagUrl)
            if let data = data,
                let tags = try? JSONDecoder().decode([RepositoryTag].self, from: data) {
                let versions = tags.flatMap { Version.init($0.name) }.filter { $0.patch.index(of: "-") == nil }.sorted()
                if let mostRecent = versions.last {
                    major = mostRecent.major
                    minor = mostRecent.minor
                }
            }
        }
        
        if major == nil {
            print("Major version:", terminator: "")
            major = Int(readLine()!)
            print("Minor version:", terminator: "")
            minor = Int(readLine()!)
        }
        
        let dependencyObject = Package.Dependency(url: fullUrl, major: major!, minor: minor!)
        
        package.dependencies.append(dependencyObject)
        try package.write()
        
        _ = try SPM.capture(arguments: ["package", "show-dependencies"])
    }
    
}

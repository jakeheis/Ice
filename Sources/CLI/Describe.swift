//
//  Describe.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI
import Core
import Rainbow

class DescribeCommand: Command {
    
    let name = "describe"
    let shortDescription = "Describes the given package"

    let package = Parameter()
    
    func execute() throws {
        if let entry = Ice.registry.get(package.value) {
            guard let ref = RepositoryReference(entry.url) else {
                fatalError("Malformed registry entry: \(entry.url)")
            }
            try printRef(ref, description: entry.description)
        } else if let ref = RepositoryReference(package.value) {
            try printRef(ref)
        }
    }
    
    func printRef(_ ref: RepositoryReference, description: String? = nil) throws {
        printDetail(title: "Name", value: ref.name)
        printDetail(title: "URL", value: ref.url)
        if let description = description {
            printDetail(title: "Description", value: description)
        }
        
        do {
            if let version = try ref.latestVersion() {
                printDetail(title: "Latest", value: version.raw)
                return
            }
        } catch {}
        
        throw IceError(message: "couldn't contact remote; ensure valid reference")
    }
    
    func printDetail(title: String, value: String) {
        let padding = String(repeating: " ", count: 11 - title.characters.count)
        print("\(padding)\(title): ".blue + value)
    }
    
}

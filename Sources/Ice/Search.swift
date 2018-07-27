//
//  Search.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import Foundation
import IceKit
import Rainbow
import SwiftCLI

class SearchCommand: Command {
    
    let name = "search"
    let shortDescription = "Searches for the given package"
    
    let query = Parameter()
    
    let onlyName = Flag("-n", "--name-only", description: "Only search for packages matching the name")
    
    func execute() throws {
        let entries = try Ice.registry.search(query: query.value, includeDescription: !onlyName.value)
        
        if entries.isEmpty {
            stdout <<< "Warning: ".yellow + "no results found"
            guard let githubQuery = query.value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                fatalError()
            }
            stdout <<< ""
            stdout <<< "Try a Github search: https://github.com/search?q=\(githubQuery)+language:swift&s=stars"
            stdout <<< ""
        } else {
            stdout <<< ""
            for entry in entries {
                printDetail(title: "Name", value: entry.name, prefix: "● ")
                printDetail(title: "URL", value: entry.url)
                if let description = entry.description {
                    printDetail(title: "Description", value: description)
                }
                stdout <<< ""
            }
        }
    }
    
    func printDetail(title: String, value: String, prefix: String = "  ") {
        stdout <<< "\(prefix)\(title): ".blue + value
    }
    
}

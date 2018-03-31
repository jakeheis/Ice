//
//  Outdated.swift
//  CLI
//
//  Created by Jake Heiser on 3/9/18.
//

import Core
import SwiftCLI
import SwiftyTextTable

class OutdatedCommand: Command {
    
    let name = "outdated"
    let shortDescription = "List the dependencies which have newer versions"
    
    func execute() throws {
        let package = try Package.load(directory: ".")
        guard !package.dependencies.isEmpty else {
            return
        }
        guard Resolved.filePath.exists else {
            stdout <<< "Package.resolved has not been created; run `ice resolve`"
            return
        }
        let resolved = try Resolved.load(from: ".")
        
        let nameCol = TextTableColumn(header: "Name")
        let wantedCol = TextTableColumn(header: "Wanted")
        let resolvedCol = TextTableColumn(header: "Resolved")
        let latestCol = TextTableColumn(header: "Latest")
        
        var table = TextTable(columns: [nameCol, wantedCol, resolvedCol, latestCol])
        
        for dep in package.dependencies {
            let ref = RepositoryReference(url: dep.url)
            let pin = resolved.findPin(url: dep.url)
            
            let name = ref.name
            let wanted = dep.requirement.type == .range ? "\(dep.requirement.lowerBound!) ..< \(dep.requirement.upperBound!)" : dep.requirement.identifier!
            let resolved = pin?.state.version ?? pin?.state.branch ?? pin?.state.revision ?? "(none)"
            let latest = try ref.latestVersion()?.description ?? "(unknown)"
            
            table.addRow(values: [name, wanted, resolved, latest])
        }
        
        stdout <<< table.render()
    }
    
}

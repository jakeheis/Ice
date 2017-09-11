//
//  Describe.swift
//  Ice
//
//  Created by Jake Heiser on 7/22/17.
//

import SwiftCLI

class DescribeCommand: Command {
    
    let name = "describe"
    let shortDescription = "Describes the given package"

    let package = Parameter()
    
    func execute() throws {
        
    }
    
}

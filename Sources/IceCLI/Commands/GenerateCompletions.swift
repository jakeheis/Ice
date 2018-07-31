//
//  GenerateCompletions.swift
//  Ice
//
//  Created by Jake Heiser on 9/10/17.
//

import SwiftCLI

class GenerateCompletionsCommand: Command {
    
    let name = "generate-completions"
    let shortDescription = "Generates shell completions"
    
    let cli: CLI
    
    init(cli: CLI) {
        self.cli = cli
    }
    
    func execute() throws {
        let completionGenerator = ZshCompletionGenerator(cli: cli)
        completionGenerator.writeCompletions()
    }
    
}

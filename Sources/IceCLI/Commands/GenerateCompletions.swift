//
//  GenerateCompletions.swift
//  Ice
//
//  Created by Jake Heiser on 9/10/17.
//

import SwiftCLI

enum CompletionFunctions: String {
    case listRegistry = "_list_registry"
    case listDependencies = "_list_dependencies"
    case listTargets = "_list_targets"
}

extension Completion {
    static func function(_ function: CompletionFunctions) -> Completion {
        return .function(function.rawValue)
    }
}

class GenerateCompletionsCommand: Command {
    
    let name = "generate-completions"
    let shortDescription = "Generates zsh completions"
    
    let cli: CLI
    
    init(cli: CLI) {
        self.cli = cli
    }
    
    func execute() throws {
        let completionGenerator = ZshCompletionGenerator(cli: cli, functions: generateFunctions())
        completionGenerator.writeCompletions()
    }
    
    func generateFunctions() -> [String: String] {
        return [
            CompletionFunctions.listRegistry.rawValue: """
            local packages
            packages=( $(grep name ~/.icebox/Registry/shared/Registry/*.json | grep -o '"[^"]*"' | grep -v "name" | cut -c 2- | rev | cut -c 2- | rev) )
            _describe '' packages
            """,
            CompletionFunctions.listDependencies.rawValue: """
            local dependencies
            dependencies=( $(grep -e "\\.package" Package.swift | grep -o 'url: "[^"]*"' | grep -o '/[^/]*"' | cut -c 2- | rev | cut -c 2- | rev) )
            _describe '' dependencies
            """,
            CompletionFunctions.listTargets.rawValue: """
            local targets
            targets=( $(grep -e "\\.target\\|\\.testTarget" Package.swift | grep -o 'name: "[^"]*"' | cut -c 8- | rev | cut -c 2- | rev) )
            _describe '' targets
            """,
        ]
    }
    
}

//
//  Shared.swift
//  CLI
//
//  Created by Jake Heiser on 4/19/18.
//

import Core
import Foundation
import SwiftCLI

struct InitializerOptions {
    static let library = Flag("-l", "--lib", "--library")
    static let executable = Flag("-e", "--exec", "--executable")
    static let typeGroup =  OptionGroup(options: [library, executable], restriction: .atMostOne)
}

extension Package.Dependency.Requirement {
    
    static func validate(_ string: String) -> Bool {
        if Version(string) != nil {
            return true
        }
        var set = CharacterSet.alphanumerics
        set.insert(charactersIn: "-_")
        return string.trimmingCharacters(in: set).isEmpty
    }
    
    static func create(from: String) -> Package.Dependency.Requirement {
        if let version = Version(from) {
            return .init(version: version)
        } else {
            let type: Package.Dependency.Requirement.RequirementType
            if !from.trimmingCharacters(in: CharacterSet(charactersIn: "1234567890abcdef")).isEmpty {
                type = .branch
            } else if from.count == 40 {
                type = .revision
            } else {
                WriteStream.stdout <<< "Is this a branch? [y/N]"
                if Input.readBool(prompt: ">") {
                    type = .branch
                } else {
                    type = .revision
                }
            }
            return .init(type: type, lowerBound: nil, upperBound: nil, identifier: from)
        }
    }
    
    static func read() -> Package.Dependency.Requirement {
        WriteStream.stdout <<< "Enter in a version, branch name, or commit SHA:"
        let input = Input.readLine(prompt: ">", validation: validate, errorResponse: { (input) in
            WriteStream.stdout <<< "A version must be of the form 'major.minor.patch', and a branch or SHA must be composed of valid characters"
        })
        return create(from: input)
    }
    
}

extension Command {
    var verboseOut: WriteStream {
        return verbose.value ? WriteStream.stdout : WriteStream.null
    }
}

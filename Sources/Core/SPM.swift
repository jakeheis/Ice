//
//  SPM.swift
//  Ice
//
//  Created by Jake Heiser on 7/21/17.
//

import Foundation
import FileKit
import Regex
import Exec
import Transformers

public class SPM {
    
    public enum InitType: String {
        case executable
        case library
    }

    let path: Path
    
    public init(path: Path = Path.current) {
        self.path = path
    }
    
    public func initPackage(type: InitType?) throws {
        var args = ["package", "init"]
        if let type = type {
            args += ["--type", type.rawValue]
        }
        try exec(arguments: args).execute(transform: Transformers.initPackage)
    }
    
    // MARK: - Building
    
    public func build(release: Bool) throws {
        try resolve()
        
        var args = ["build"]
        if release {
            args += ["-c", "release"]
        }
        try exec(arguments: args).execute(transform: Transformers.build)
    }
    
    public func run(release: Bool, executable: [String]) throws {
        try resolve()
        
        try build(release: release)
        
        var args = ["run", "--skip-build"]
        if release {
            args += ["-c", "release"]
        }
        args += executable
        try exec(arguments: args).execute()
    }
    
    public func test(filter: String?) throws {
        try resolve()
        
        var args = ["test"]
        if let filter = filter {
            args += ["--filter", filter]
        }
        try exec(arguments: args).execute(transform: Transformers.test)
    }
    
    public func resolve() throws {
        try exec(arguments: ["package", "-v", "resolve"]).execute(transform: Transformers.resolve)
    }
    
    // MARK: -
    
    public func clean() throws {
        try exec(arguments: ["package", "clean"]).execute()
    }
    
    public func reset() throws {
        try exec(arguments: ["package", "reset"]).execute()
    }
    
    public func update() throws {
        try exec(arguments: ["package", "update"]).execute(transform: Transformers.update)
    }

    public func generateXcodeProject() throws {
        try exec(arguments: ["package", "generate-xcodeproj"]).execute()
    }
    
    public func showBinPath(release: Bool = false) throws -> String {
        var args = ["build", "--show-bin-path"]
        if release {
            args += ["-c", "release"]
        }
        let path = try exec(arguments: args).capture().stdout
        guard !path.isEmpty else {
            throw IceError(message: "couldn't retrieve executable path")
        }
        return path.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func dumpPackage() throws -> Data {
        let data = try exec(arguments: ["package", "dump-package"]).captureData().stdout
        guard let jsonStart = data.index(of: UInt8("{".cString(using: .ascii)![0])) else {
            throw IceError(message: "couldn't parse package")
        }
        return data[jsonStart...]
    }

    // MARK: -
    
    func exec(arguments: [String]) -> Exec {
        return Exec(command: "swift", args: arguments, in: path.rawValue)
    }
    
}

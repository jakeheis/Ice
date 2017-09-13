//
//  SPM.swift
//  Ice
//
//  Created by Jake Heiser on 7/21/17.
//

import Foundation
import FileKit
import Exec
import Regex

public class SPM {

    let path: Path
    
    public init(path: Path = Path.current) {
        self.path = path
    }
    
    public enum InitType: String {
        case executable
        case library
    }
    
    class CreatingPackageMatch: RegexMatch, Matchable {
        static let regex = Regex("(Creating .* package): (.*)")
        var packageType: String { return captures[0] }
        var packageName: String { return captures[1] }
    }
    
    class CreateFileMatch: RegexMatch, Matchable {
        static let regex = Regex("Creating ([^:]+)$")
        var filePath: String { return captures[0] }
    }
    
    public func initPackage(type: InitType?) throws {
        var args = ["package", "init"]
        if let type = type {
            args += ["--type", type.rawValue]
        }
        try exec(arguments: args).execute(transform: { (t) in
            t.first("\n")
            t.replace(CreatingPackageMatch.self) { $0.packageType + ": " + $0.packageName.blue.bold + "\n" }
            t.replace(CreateFileMatch.self) { "    create ".blue + $0.filePath }
            t.last("\n")
        })
    }
    
    public func clean() throws {
        try exec(arguments: ["package", "clean"]).execute()
    }
    
    public func reset() throws {
        try exec(arguments: ["package", "reset"]).execute()
    }

    public func generateXcodeProject() throws {
        try exec(arguments: ["package", "generate-xcodeproj"]).execute()
    }
    
    func showBinPath(release: Bool = false) throws -> String {
        var args = ["build", "--show-bin-path"]
        if release {
            args += ["-c", "release"]
        }
        let path = try exec(arguments: args).capture()
        guard !path.isEmpty else {
            throw IceError(message: "couldn't retrieve executable path")
        }
        return path.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func dumpPackage() throws -> Data {
        let data = try exec(arguments: ["package", "dump-package"]).captureData()
        guard let jsonStart = data.index(of: UInt8("{".cString(using: .ascii)![0])) else {
            throw IceError(message: "couldn't parse package")
        }
        return data[jsonStart...]
    }

    func exec(arguments: [String]) -> Exec {
        return Exec(command: "swift", args: arguments, in: path.rawValue)
    }
    
}

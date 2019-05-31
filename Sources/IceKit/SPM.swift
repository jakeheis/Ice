//
//  SPM.swift
//  Ice
//
//  Created by Jake Heiser on 7/21/17.
//

import Foundation
import PathKit
import SwiftCLI

public enum SwiftExecutable {
    
    public static var toolchainPath: Path? = {
        let tmpFile = Path.current + "._ice.swift"
        if !tmpFile.exists {
            try? tmpFile.write("")
        }
        
        let capture = CaptureStream()
        let task = Task(executable: "swift", arguments: ["-v", tmpFile.string], stdout: WriteStream.null, stderr: capture)
        task.runSync()
        
        try? tmpFile.delete()
        
        guard let compilerPath = capture.readAll().components(separatedBy: "\n").first(where: { $0.hasPrefix("/") }),
            let range = compilerPath.range(of: ".xctoolchain/") else {
                return nil
        }
        
        let portion = String(compilerPath.prefix(upTo: range.upperBound))
        return Path(portion).normalize()
    }()
    
    public static var version: SwiftToolsVersion? = {
        if let content = try? Task.capture("swift", "--version").stdout,
            let match = Regex("Swift version ([0-9]\\.[0-9](\\.[0-9])?)(-dev)? ").firstMatch(in: content),
            let versionString = match.captures[0],
            let version = SwiftToolsVersion(versionString) {
            return version
        }
        return nil
    }()
    
}

public class SPM {
    
    public let directory: Path
    
    public init(directory: Path = .current) {
        self.directory = directory
    }
    
    // MARK: - Init project
    
    public enum InitType: String {
        case executable
        case library
    }
    
    public func initPackage(type: InitType?) throws {
        var args = ["package", "init"]
        if let type = type {
            args += ["--type", type.rawValue]
        }
        try runSwift(args: args, transformer: .initialize)
    }
    
    // MARK: - Building / testing
    
    public enum BuildOption {
        case includeTests
        case target(String)
        case product(String)
    }
    
    public func build(release: Bool, buildOption: BuildOption? = nil) throws {
        // Resolve verbosely first because for some reason, SPM does not flush pipe
        // when printing package resolution info
        try resolve()
        
        var args = ["build"]
        if release {
            args += ["-c", "release"]
        }
        if let buildOption = buildOption {
            switch buildOption {
            case .includeTests: args.append("--build-tests")
            case let .target(target): args += ["--target", target]
            case let .product(product): args += ["--product", product]
            }
        }
        try runSwift(args: args, transformer: .build)
    }
    
    public func run(release: Bool, executable: [String]) throws -> Task {
        let arguments = try formArgumentsForRun(release: release, executable: executable)
        let task = Task(executable: "swift", arguments: arguments, directory: directory.string)
        task.runAsync()
        return task
    }
    
    public func runWithoutReturning(release: Bool, executable: [String]) throws -> Never {
        let arguments = try formArgumentsForRun(release: release, executable: executable)
        try Task.execvp("swift", arguments: arguments, directory: directory.string)
    }
    
    public func test(filter: String?) throws {
        try build(release: false, buildOption: .includeTests)
        
        var args = ["test"]
        if let filter = filter {
            args += ["--filter", filter]
        }
        try runSwift(args: args, transformer: .test)
    }
    
    public func resolve(silent: Bool = false) throws {
        let args = ["package", "-v", "resolve"]
        if silent {
            _ = try captureSwift(args: args)
        } else {
            try runSwift(args: args, transformer: .resolve)
        }
        
    }
    
    // MARK: -
    
    public func clean() throws {
        try runSwift(args: ["package", "clean"])
    }
    
    public func reset() throws {
        try runSwift(args: ["package", "reset"])
    }
    
    public func update() throws {
        try runSwift(args: ["package", "update"], transformer: .resolve)
    }
    
    public func generateXcodeProject(codeCoverage: Bool) throws {
        if codeCoverage {
            try runSwift(args: ["package", "generate-xcodeproj", "--enable-code-coverage"], transformer: .xc)
        }
        else {
            try runSwift(args: ["package", "generate-xcodeproj"], transformer: .xc)
        }
    }
    
    public func generateTests(for packageTargets: [Package.Target]) throws {
        #if os(macOS)
        guard let version = SwiftExecutable.version, version >= SwiftToolsVersion(major: 4, minor: 1, patch: 0) else {
            throw IceError(message: "test list generation only supported for Swift 4.1 and above")
        }
        
        let testDirectory = directory + "Tests"
        for target in packageTargets where target.type == .test {
            let path = testDirectory + target.name + "XCTestManifests.swift"
            if path.exists {
                try path.delete()
            }
        }
        
        let linuxMain = testDirectory + "LinuxMain.swift"
        if linuxMain.exists {
            try linuxMain.delete()
        }
        
        try runSwift(args: ["test", "--generate-linuxmain"], transformer: .build)
        
        #else
        
        throw IceError(message: "test list generation is not supported on Linux")

        #endif
    }
    
    public func showBinPath(release: Bool = false) throws -> String {
        var args = ["build", "--show-bin-path"]
        if release {
            args += ["-c", "release"]
        }
        let path = try captureSwift(args: args).stdout
        guard !path.isEmpty else {
            throw IceError(message: "couldn't retrieve bin path")
        }
        return path.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public enum DumpMode {
        case model
        case packageDescription
    }
    
    public func dumpPackage(mode: DumpMode) throws -> Data {
        switch mode {
        case .model:
            let content = try captureSwift(args: ["package", "dump-package"]).stdout
            guard let jsonStart = content.firstIndex(of: "{"), let data = String(content[jsonStart...]).data(using: .utf8) else {
                throw IceError(message: "can't parse package")
            }
            return data
        case .packageDescription:
            guard let toolchainPath = SwiftExecutable.toolchainPath else {
                throw IceError(message: "can't find Swift toolchain")
            }
            
            guard let packageFile = PackageFile.find(in: directory) else {
                throw IceError(message: "can't find Package.swift")
            }
            
            let libVersion: String
            if packageFile.toolsVersion >= .v4_2 {
                libVersion = "4_2"
            } else {
                libVersion = "4"
            }
            let libPath = toolchainPath + "usr" + "lib" + "swift" + "pm" + libVersion
            
            guard let content = try? Task.capture("swiftc", "--driver-mode=swift", "-I", libPath.string, "-L", libPath.string, "-lPackageDescription", packageFile.path.string, "-fileno", "1"),
                let data = content.stdout.data(using: .utf8) else {
                    throw IceError(message: "can't parse Package.swift")
            }
            return data
        }
    }
        
    // MARK: - Helpers
    
    private func runSwift(args: [String], transformer: TransformerPair? = nil) throws {
        let stdout: WritableStream = transformer?.stdout ?? WriteStream.stdout
        let stderr: WritableStream = transformer?.stderr ?? WriteStream.stderr
        let task = Task(executable: "swift", arguments: args, directory: directory.string, stdout: stdout, stderr: stderr)
        let result = task.runSync()
        transformer?.wait()
        
        guard result == 0 else {
            throw IceError(exitStatus: result)
        }
    }
    
    private func captureSwift(args: [String]) throws -> CaptureResult {
        do {
            return try Task.capture("swift", arguments: args, directory: directory.string)
        } catch let error as CaptureError {
            let message: String?
            if error.captured.stderr.isEmpty {
                message = nil
            } else {
                if let match = Regex("[eE]rror: (.*)$").firstMatch(in: error.captured.stderr), let rest = match.captures[0] {
                    message = rest
                } else {
                    message = error.captured.stderr
                }
            }
            
            throw IceError(message: message, exitStatus: error.exitStatus)
        }
    }
    
    private func formArgumentsForRun(release: Bool, executable: [String]) throws -> [String] {
        try build(release: release)
        
        var args = ["run", "--skip-build"]
        if release {
            args += ["-c", "release"]
        }
        args += executable
        
        return args
    }
    
}

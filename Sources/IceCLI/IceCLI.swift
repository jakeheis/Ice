//
// IceCLI.swift
// IceCLI
//

import Foundation
import IceKit
import PathKit
import Rainbow
import SwiftCLI

public class IceCLI {
    
    public static let name = "ice"
    public static let description = "ice package manager"
    
    private static let globalRootKey = "ICE_GLOBAL_ROOT"
    
    public init() {}
    
    public func run() -> Never {
        Rainbow.enabled = Term.isTTY
        
        let ice = createIce()
        
        let cli = CLI(name: IceCLI.name, version: Ice.version.string, description: IceCLI.description)
        cli.commands = [
            AddCommand(ice: ice),
            BuildCommand(),
            CleanCommand(),
            ConfigGroup(ice: ice),
            DescribeCommand(ice: ice),
            DumpCommand(),
            FormatCommand(ice: ice),
            GenerateCompletionsCommand(cli: cli),
            GenerateTestListCommand(),
            InitCommand(ice: ice),
            NewCommand(ice: ice),
            OutdatedCommand(ice: ice),
            ProductGroup(ice: ice),
            RemoveCommand(ice: ice),
            RegistryGroup(ice: ice),
            ResetCommand(),
            ResolveCommand(),
            RunCommand(),
            SearchCommand(ice: ice),
            TargetGroup(ice: ice),
            TestCommand(),
            ToolsVersionGroup(ice: ice),
            UpdateCommand(ice: ice),
            VersionCommand(),
            XcCommand(ice: ice)
        ]
        cli.aliases.removeValue(forKey: "-v") // Reserve -v for verbose flag, not alias to version cmd
        cli.globalOptions = [GlobalOptions.verbose]
        cli.versionCommand = nil
        cli.goAndExit()
    }
    
    private func createIce() -> Ice {
        let root: Path
        if let rootStr = ProcessInfo.processInfo.environment[IceCLI.globalRootKey] {
            root = Path(rootStr)
        } else {
            root = Ice.defaultRoot
        }
        
        guard let ice = Ice(root: root) else {
            WriteStream.stderr <<< "Error: ".bold.red + "couldn't set up Ice at \(root)"
            exit(1)
        }
        return ice
    }
    
}

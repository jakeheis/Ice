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
            BuildCommand(ice: ice),
            CleanCommand(),
            ConfigGroup(ice: ice),
            DescribeCommand(ice: ice),
            DumpCommand(),
            FormatCommand(ice: ice),
            GenerateCompletionsCommand(cli: cli),
            GenerateTestListCommand(ice: ice),
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
            TestCommand(ice: ice),
            ToolsVersionGroup(ice: ice),
            UpdateCommand(ice: ice),
            VersionCommand(),
            XcCommand(ice: ice)
        ]
        
        cli.parser.responders.insert(ForwardCompilerOptionResponse(), at: 0)
        cli.versionCommand = nil
        cli.globalOptions = [Logger.verboseFlag]
        cli.helpMessageGenerator = DefaultHelpMessageGenerator(colorError: true, boldError: true)
        
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

class ForwardCompilerOptionResponse: ParserResponse {

    func canRespond(to arguments: ArgumentList, state: Parser.State) -> Bool {
        guard case let .routed(cmd, _) = state.routeState, cmd.command is ForwardFlagsCommand else {
            return false
        }
        return ForwardFlagsCommand.keys.contains(arguments.peek())
    }
    
    func respond(to arguments: ArgumentList, state: Parser.State) throws -> Parser.State {
        let keyName = arguments.pop()
        
        guard let key = state.optionRegistry.key(for: keyName) else {
            assertionFailure()
            return state
        }
        
        guard arguments.hasNext() else {
             throw OptionError(command: state.command, kind: .expectedValueAfterKey(keyName))
        }
        
        let result = key.update(to: arguments.pop())
        if case let .failure(error) = result {
           throw OptionError(command: state.command, kind: .invalidKeyValue(key, keyName, error))
        }

        return state
    }

    func cleanUp(arguments: ArgumentList, state: Parser.State) throws -> Parser.State { state }

}

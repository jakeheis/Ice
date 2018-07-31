import Foundation
import IceKit
import PathKit
import Rainbow
import SwiftCLI

Rainbow.enabled = Term.isTTY

let root: Path
if let rootStr = ProcessInfo.processInfo.environment["ICE_GLOBAL_ROOT"] {
    root = Path(rootStr)
} else {
    root = Ice.defaultRoot
}

let ice: Ice
do {
    ice = try Ice(root: root)
} catch {
    WriteStream.stderr <<< "Error: ".bold.red + "couldn't set up Ice at \(root)"
    exit(1)
}

let cli = CLI(name: "ice", version: ice.version, description: "ice package manager")
cli.commands = [
    AddCommand(ice: ice),
    BuildCommand(),
    CleanCommand(),
    ConfigGroup(ice: ice),
    DescribeCommand(ice: ice),
    DumpCommand(),
    GenerateCompletionsCommand(cli: cli),
    InitCommand(),
    NewCommand(),
    OutdatedCommand(),
    ProductGroup(),
    RemoveCommand(),
    RegistryGroup(ice: ice),
    ResetCommand(),
    ResolveCommand(),
    RunCommand(),
    SearchCommand(ice: ice),
    TargetGroup(),
    TestCommand(),
    ToolsVersionGroup(),
    UpdateCommand(),
    VersionCommand(ice: ice),
    XcCommand()
]
cli.globalOptions = [GlobalOptions.verbose]
cli.versionCommand = nil
cli.goAndExit()

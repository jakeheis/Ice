import IceKit
import Rainbow
import SwiftCLI

Rainbow.enabled = Term.isTTY

let ice = CLI(name: "ice", version: Ice.version, description: "ice package manager")
ice.commands = [
    AddCommand(),
    BuildCommand(),
    CleanCommand(),
    ConfigGroup(),
    DescribeCommand(),
    DumpCommand(),
    GenerateCompletionsCommand(cli: ice),
    InitCommand(),
    NewCommand(),
    OutdatedCommand(),
    ProductGroup(),
    RemoveCommand(),
    RegistryGroup(),
    ResetCommand(),
    ResolveCommand(),
    RunCommand(),
    SearchCommand(),
    TargetGroup(),
    TestCommand(),
    ToolsVersionGroup(),
    UpdateCommand(),
    VersionCommand(),
    XcCommand()
]
ice.globalOptions = [GlobalOptions.verbose]
ice.versionCommand = nil
ice.goAndExit()

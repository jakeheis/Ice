import SwiftCLI
import Rainbow
import Core

Rainbow.enabled = Term.isTTY

let _verbose = Flag("-v", "--verbose")
extension Command {
    var verbose: Flag {
        return _verbose
    }
}

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
    UpdateCommand(),
    VersionCommand(),
    XcCommand()
]
ice.globalOptions = [_verbose]
ice.versionCommand = nil
ice.goAndExit()

import SwiftCLI
import Rainbow
import Core

Rainbow.enabled = Term.isTTY

let _verbose = Flag("-v", "--verbose")
extension Command {
    var verbose: Flag {
        return _verbose
    }
    
    func verboseLog(_ content: String) {
        if verbose.value {
            stdout <<< content
        }
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
    GlobalGroup(),
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
    XcCommand()
]
ice.globalOptions = [_verbose]
ice.goAndExit()

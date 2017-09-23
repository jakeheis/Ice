import SwiftCLI
import Rainbow
import Core

Rainbow.enabled = Term.isTTY

let ice = CLI(name: "ice", version: "0.0.1", description: "ice package manager")
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
    RemoveCommand(),
    RegistryGroup(),
    ResetCommand(),
    RunCommand(),
    SearchCommand(),
    TargetGroup(),
    TestCommand(),
    UpgradeCommand(),
    XcCommand()
]
ice.goAndExit()

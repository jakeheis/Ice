import SwiftCLI
import Rainbow
import Core

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
    GlobalGroup(),
    InitCommand(),
    NewCommand(),
    ProductGroup(),
    RemoveCommand(),
    RegistryGroup(),
    ResetCommand(),
    RunCommand(),
    SearchCommand(),
    TargetGroup(),
    TestCommand(),
    UpdateCommand(),
    UpgradeCommand(),
    XcCommand()
]
ice.goAndExit()

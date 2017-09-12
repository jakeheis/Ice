import SwiftCLI

let ice = CLI(name: "ice", version: "0.0.1", description: "ice package manager")
ice.commands = [
    AddCommand(),
    BuildCommand(),
    CleanCommand(),
    ConfigGroup(),
    DependCommand(),
    DescribeCommand(),
    DumpCommand(),
    GenerateCompletionsCommand(cli: ice),
    GlobalGroup(),
    InitCommand(),
    NewCommand(),
    RemoveCommand(),
    ResetCommand(),
    RunCommand(),
    SearchCommand(),
    TargetCommand(),
    TestCommand(),
    UpgradeCommand(),
    XcCommand()
]
ice.goAndExit()

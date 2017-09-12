import SwiftCLI

let ice = CLI(name: "ice", version: "0.0.1", description: "ice package manager")
ice.commands = [
    AddCommand(),
    BuildCommand(),
    CleanCommand(),
    ConfigGroup(),
    DependCommand(),
    DumpCommand(),
    DescribeCommand(),
    GenerateCompletionsCommand(cli: ice),
    InitCommand(),
    TargetCommand(),
    NewCommand(),
    RemoveCommand(),
    ResetCommand(),
    RunCommand(),
    SearchCommand(),
    TestCommand(),
    UpgradeCommand(),
    XcCommand()
]
ice.goAndExit()

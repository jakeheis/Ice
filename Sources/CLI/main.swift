import SwiftCLI

let cli = CLI(name: "ice", version: "0.0.1", commands: [
    AddCommand(),
    BuildCommand(),
    CleanCommand(),
    ConfigGroup(),
    DependCommand(),
    DumpCommand(),
    DescribeCommand(),
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
])
cli.description = "ice package manager"
cli.commands.append(GenerateCompletionsCommand(cli: cli))
cli.goAndExit()

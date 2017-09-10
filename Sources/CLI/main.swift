import Foundation
import SwiftCLI

CLI.setup(name: "ice", version: "0.0.1", description: "ice package manager")

CLI.register(commands: [
    AddCommand(),
    BuildCommand(),
    CleanCommand(),
    ConfigCommand(),
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

//exit(CLI.debugGo(with: "ice upgrade -G FlockCLI"))
exit(CLI.go())

import Foundation
import SwiftCLI

CLI.setup(name: "ice")

CLI.register(commands: [
    AddCommand(),
    BuildCommand(),
    DependCommand(),
    DescribeCommand(),
    InitCommand(),
    ModuleCommand(),
    NewCommand(),
    RemoveCommand(),
    RunCommand(),
    SearchCommand(),
    TestCommand(),
    UpgradeCommand(),
    XcCommand()
])

exit(CLI.go())

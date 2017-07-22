import Foundation
import SwiftCLI
import Files

CLI.setup(name: "bark")

CLI.register(command: InitCommand())
CLI.register(command: TakeoverCommand())
CLI.register(command: AddCommand())

exit(CLI.go())

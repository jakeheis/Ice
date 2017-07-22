import Foundation
import SwiftCLI
import Files

CLI.setup(name: "bark")

CLI.register(command: InitCommand())
CLI.register(command: TakeoverCommand())
CLI.register(command: AddCommand())
CLI.register(command: XcodeCommand())

exit(CLI.go())

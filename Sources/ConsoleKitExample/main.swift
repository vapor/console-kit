import ConsoleKit
import Foundation
import Logging

let console: Console = Terminal()
var input = CommandInput(arguments: ProcessInfo.processInfo.arguments)
var context = CommandContext(console: console, input: input)

var commands = Commands(enableAutocomplete: true)
commands.use(DemoCommand(), as: "demo", isDefault: false)

do {
    let group = commands
        .group(help: "An example command-line application built with ConsoleKit")
    try console.run(group, input: input)
} catch let error {
    console.error("\(error)")
    exit(1)
}

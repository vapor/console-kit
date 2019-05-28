import ConsoleKit
import Foundation

let console: Console = Terminal()
var input = CommandInput(arguments: CommandLine.arguments)

var config = CommandConfiguration()
config.use(DemoCommand(), as: "demo", isDefault: true)

do {
    let commands = try config.resolve().group(help: "An example command-line application built with ConsoleKit")
    try console.run(commands, input: &input)
} catch let error {
    console.error(error.localizedDescription)
    exit(1)
}

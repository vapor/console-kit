import ConsoleKit
import Foundation
import Logging

@main
struct ConsoleKitExample {
    static func main() {
        let console = Terminal()
        let input = CommandInput(arguments: ProcessInfo.processInfo.arguments)

        var commands = Commands(enableAutocomplete: true)
        commands.use(DemoCommand(), as: "demo", isDefault: false)

        do {
            let group = commands.group(help: "An example command-line application built with ConsoleKit")
            try console.run(group, input: input)
        } catch let error {
            console.error("\(error)")
        }
    }
}

import ConsoleKit
import Foundation

@main
struct AsyncExample {
    static func main() async throws {
        let console = Terminal()
        let input = CommandInput(arguments: ProcessInfo.processInfo.arguments)

        var commands = AsyncCommands(enableAutocomplete: true)
        commands.use(DemoCommand(), as: "demo", isDefault: false)

        do {
            let group = commands
                .group(help: "An example command-line application built with ConsoleKit")
            try await console.run(group, input: input)
        } catch let error {
            console.error("\(error)")
        }
    }
}

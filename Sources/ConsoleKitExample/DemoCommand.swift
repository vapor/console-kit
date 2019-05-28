import ConsoleKit

final class DemoCommand: Command {
    struct Signature: CommandSignature {
        let colored = Option<Bool>(
            name: "colored",
            short: "c",
            type: .value(default: "true"),
            help: "Whether the output should be color or just black and white."
        )
        let loadingFrames = Option<String>(name: "loading", type: .value, help: """
        Custom frames for the loading bar.
        The value for this option should be a comma separated list of characters to use.
        """)
    }

    let signature: DemoCommand.Signature = Signature()

    let help: String? = "A demonstration of what ConsoleKit can do"

    func run(using context: CommandContext<DemoCommand>) throws {
        let funDemoText: ConsoleText
        if try context.option(\.colored) ?? false {
            funDemoText = [
                ConsoleTextFragment(string: "D", style: .init(color: .red)),
                ConsoleTextFragment(string: "e", style: .init(color: .yellow)),
                ConsoleTextFragment(string: "m", style: .init(color: .green)),
                ConsoleTextFragment(string: "o", style: .init(color: .blue)),
                ConsoleTextFragment(string: "!", style: .init(color: .magenta)),
            ]
        } else {
            funDemoText = "Demo!"
        }

        context.console.output("Welcome to the ConsoleKit " + funDemoText)
        let name = context.console.ask("What is your name?".consoleText(.info))
        context.console.print("Hello, \(name) 👋")

        if try context.option(\.colored) ?? false {
            context.console.info("Here's an example of loading")
        } else {
            context.console.print("Here's an example of loading")
        }

        if let frames = try context.option(\.loadingFrames) {
            let loadingBar = context.console.customActivity(frames: frames.split(separator: ",").map(String.init))
            loadingBar.start()

            context.console.wait(seconds: 2)
            loadingBar.succeed()
        } else {
            let loadingBar = context.console.loadingBar(title: "Loading")
            loadingBar.start()

            context.console.wait(seconds: 2)
            loadingBar.succeed()
        }
    }
}

import ConsoleKit

final class DemoCommand: Command {
    struct Signature: CommandSignature {
        @Flag(name: "color", short: "c", help: "Enables colorized output")
        var color: Bool

        @Option(name: "frames", help: "Custom frames for the loading bar\nUse a comma-separated list")
        var frames: String?

        init() {}
    }

    var help: String {
        "A demonstration of what ConsoleKit can do"
    }

    func run(using context: CommandContext, signature: Signature) throws {
        let funDemoText: ConsoleText
        if signature.color {
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

        if signature.color {
            context.console.info("Here's an example of loading")
        } else {
            context.console.print("Here's an example of loading")
        }
    
        func run(loadingBar: ActivityIndicator<some ActivityIndicatorType>) {
            loadingBar.start()
            context.console.wait(seconds: 2)
            loadingBar.succeed()
        }

        if let frames = signature.frames {
            run(loadingBar: context.console.customActivity(frames: frames.split(separator: ",").map(String.init)))
        } else {
            run(loadingBar: context.console.loadingBar(title: "Loading"))
        }
        
        context.console.output("Now for secure input: ", newLine: false)
        let input = context.console.input(isSecure: true)
        context.console.output("Your secure input was: \(input)")
    }
}

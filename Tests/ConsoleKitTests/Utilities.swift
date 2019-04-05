import ConsoleKit

extension String: Error {}

final class TestGroup: CommandGroup {
    let commands: Commands = [
        "test": TestCommand(),
        "sub": SubGroup()
    ]

    let options: [CommandOption] = [
        .value(name: "version", help: ["Prints the version"])
    ]

    let help = ["This is a test grouping!"]

    func run(using context: CommandContext) throws {
        if context.options["version"] == "true" {
            context.console.print("v2.0")
        }
    }
}

final class SubGroup: CommandGroup {
    let commands: Commands = [
        "test": TestCommand()
    ]

    let options: [CommandOption] = [
        .value(name: "version", help: ["Prints the version"])
    ]

    let help = ["This is a test sub grouping!"]

    func run(using context: CommandContext) throws {
        if context.options["version"] == "true" {
            context.console.print("v2.0")
        }
    }
}

final class TestCommand: Command {
    let arguments: [CommandArgument] = [
        .argument(
            name: "foo",
            help: ["A foo is required", "An error will occur if none exists"]
        )
    ]

    let options: [CommandOption] = [
        .value(name: "bar", short: "b", help: ["Add a bar if you so desire", "Try passing it"])
    ]

    let help = ["This is a test command"]

    func run(using context: CommandContext) throws {
        let foo = try context.argument("foo")
        let bar = try context.requireOption("bar")
        context.console.output("Foo: \(foo) Bar: \(bar)".consoleText(.info))
    }
}

final class TestConsole: Console {
    var testInputQueue: [String]
    var testOutputQueue: [String]
    var userInfo: [AnyHashable : Any]
    
    init() {
        self.testInputQueue = []
        self.testOutputQueue = []
        self.userInfo = [:]
    }

    func input(isSecure: Bool) -> String {
        return testInputQueue.popLast() ?? ""
    }

    func output(_ text: ConsoleText, newLine: Bool) {
        testOutputQueue.insert(text.description + (newLine ? "\n" : ""), at: 0)
    }

    func report(error: String, newLine: Bool) {
        //
    }

    func clear(_ type: ConsoleClear) {
        //
    }

    var size: (width: Int, height: Int) { return (0, 0) }
}


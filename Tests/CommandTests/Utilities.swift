import Async
import Console
import Command
import Service

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

    func run(using context: CommandContext) throws -> Future<Void> {
        if context.options["version"] == "true" {
            context.console.print("v2.0")
        } else {
            throw "unknown"
        }
        return .done(on: context.container)
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

    func run(using context: CommandContext) throws -> Future<Void> {
        if context.options["version"] == "true" {
            context.console.print("v2.0")
        } else {
            throw "unknown"
        }
        return .done(on: context.container)
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

    func run(using context: CommandContext) throws -> Future<Void> {
        let foo = try context.argument("foo")
        let bar = try context.requireOption("bar")
        context.console.info("Foo: \(foo) Bar: \(bar)")
        return .done(on: context.container)
    }
}

final class TestConsole: Console {
    var testInputQueue: [String]
    var testOutputQueue: [String]
    var extend: Extend

    init() {
        self.testInputQueue = []
        self.testOutputQueue = []
        self.extend = [:]
    }

    func input(isSecure: Bool) -> String {
        return testInputQueue.popLast() ?? ""
    }

    func output(_ string: String, style: ConsoleStyle, newLine: Bool) {
        testOutputQueue.insert(string + (newLine ? "\n" : ""), at: 0)
    }

    func report(error: String, newLine: Bool) {
        //
    }

    func clear(_ type: ConsoleClear) {
        //
    }

    var size: (width: Int, height: Int) { return (0, 0) }
}


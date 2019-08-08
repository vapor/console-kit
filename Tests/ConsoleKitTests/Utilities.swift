import ConsoleKit

extension String: Error {}

final class TestGroup: CommandGroup {
    struct Signature: CommandSignature {
        @Flag(help: "Prints the version")
        var version: Bool
        init() { }
    }

    let commands: [String : AnyCommand] = [
        "test": TestCommand(),
        "sub": SubGroup()
    ]

    let help: String = "This is a test grouping!"

    func run(using context: CommandContext, signature: Signature) throws {
        if signature.version {
            context.console.print("v2.0")
        }
    }
}

final class SubGroup: CommandGroup {
    struct Signature: CommandSignature {
        @Flag(help: "Prints the version")
        var version: Bool
        init() { }
    }

    let commands: [String : AnyCommand] = [
        "test": TestCommand()
    ]

    let help: String = "This is a test sub grouping!"

    func run(using context: CommandContext, signature: Signature) throws {
        if signature.version {
            context.console.print("v2.0")
        }
    }
}

final class TestCommand: Command {
    struct Signature: CommandSignature {
        @Argument(help: """
        A foo is required
        An error will occur if none exists
        """)
        var foo: String

        @Option(short: "b", help: """
        Add a bar if you so desire
        Try passing it
        """)
        var bar: String?

        init() { }
    }

    let help: String = "This is a test command"

    func run(using context: CommandContext, signature: Signature) throws {
        context.console.output("Foo: \(signature.foo) Bar: \(signature.bar ?? "nil")".consoleText(.info))
    }
}

final class StrictCommand: Command {
    struct Signature: CommandSignature {
        @Argument var number: Int
        @Argument var bool: Bool
        init() { }
    }
    var help: String = "I error if you pass in bad values"

    func run(using context: CommandContext, signature: Signature) throws {
        print("Done!")
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


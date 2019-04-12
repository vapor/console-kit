import ConsoleKit

extension String: Error {}

final class TestGroup: CommandGroup {
    struct Signature: Inputs {
        let version = Option<Bool>(name: "version", help: "Prints the version")
    }
    
    static let signature: TestGroup.Signature = Signature()
    
    let commands: Commands = [
        "test": TestCommand(),
        "sub": SubGroup()
    ]

    let help: String? = "This is a test grouping!"

    func run(using context: CommandContext<TestGroup>) throws {
        if try context.option(\.version) ?? false {
            context.console.print("v2.0")
        }
    }
}

final class SubGroup: CommandGroup {
    struct Signature: Inputs {
        let version = Option<Bool>(name: "version", help: "Prints the version")
    }
    
    static let signature: SubGroup.Signature = Signature()
    
    let commands: Commands = [
        "test": TestCommand()
    ]

    let help: String? = "This is a test sub grouping!"

    func run(using context: CommandContext<SubGroup>) throws {
        if try context.option(\.version) ?? false {
            context.console.print("v2.0")
        }
    }
}

final class TestCommand: Command {
    struct Signature: Inputs {
        let foo = Argument<String>(name: "foo", help: """
        A foo is required
        An error will occur if none exists
        """)
        
        let bar = Option<String>(name: "bar", short: "b", default: nil, help: """
        Add a bar if you so desire
        Try passing it
        """)
    }

    static let signature: TestCommand.Signature = Signature()
    
    let help: String? = "This is a test command"

    func run(using context: CommandContext<TestCommand>) throws {
        let foo = try context.argument(\.foo)
        let bar = try context.requireOption(\.bar)
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


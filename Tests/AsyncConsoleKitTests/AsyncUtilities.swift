import ConsoleKit
import XCTest

#if swift(>=5.5) && canImport(_Concurrency)
extension String: Error {}

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
final class TestGroup: AsyncCommandGroup {
    struct Signature: CommandSignature {
        @Flag(name: "version", help: "Prints the version")
        var version: Bool
        init() { }
    }

    let commands: [String : AnyAsyncCommand] = [
        "test": TestCommand(),
        "sub": SubGroup()
    ]

    let help: String = "This is a test grouping!"

    func run(using context: CommandContext, signature: Signature) async throws {
        if signature.version {
            context.console.print("v2.0")
        }
    }
}

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
final class SubGroup: AsyncCommandGroup {
    struct Signature: CommandSignature {
        @Flag(name: "version", help: "Prints the version")
        var version: Bool
        init() { }
    }

    let commands: [String : AnyAsyncCommand] = [
        "test": TestCommand()
    ]

    let help: String = "This is a test sub grouping!"

    func run(using context: CommandContext, signature: Signature) async throws {
        if signature.version {
            context.console.print("v2.0")
        }
    }
}

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
final class TestCommand: AsyncCommand {
    struct Signature: CommandSignature {
        @Argument(name: "foo", help: """
        A foo is required
        An error will occur if none exists
        """)
        var foo: String

        @Option(name: "bar", short: "b", help: """
        Add a bar if you so desire
        Try passing it
        """)
        var bar: String?

        @Flag(name: "baz", short: "B", help: """
        Add a baz if you so desire
        It's just a flag
        """)
        var baz: Bool

        init() { }
    }

    let help: String = "This is a test command"

    func run(using context: CommandContext, signature: Signature) async throws {
        XCTAssertEqual(signature.$foo.name, "foo")
        XCTAssertEqual(signature.$bar.name, "bar")
        XCTAssertEqual(signature.$baz.name, "baz")
        context.console.output("Foo: \(signature.foo) Bar: \(signature.bar ?? "nil")".consoleText(.info))
    }
}

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
final class StrictCommand: AsyncCommand {
    struct Signature: CommandSignature {
        @Argument(name: "number")
        var number: Int
        
        @Argument(name: "bool")
        var bool: Bool
        
        init() { }
    }
    var help: String = "I error if you pass in bad values"

    func run(using context: CommandContext, signature: Signature) async throws {
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
#endif

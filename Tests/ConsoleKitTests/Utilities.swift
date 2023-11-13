import ConsoleKit
import XCTest
import NIOConcurrencyHelpers

extension String: Error {}

final class TestGroup: CommandGroup {
    struct Signature: CommandSignature {
        @Flag(name: "version", help: "Prints the version")
        var version: Bool
        init() {}
    }

    let commands: [String: any AnyCommand] = [
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
        @Flag(name: "version", help: "Prints the version")
        var version: Bool
        init() {}
    }

    let commands: [String: any AnyCommand] = [
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

        init() {}
    }

    let help: String = "This is a test command"

    func run(using context: CommandContext, signature: Signature) throws {
        XCTAssertEqual(signature.$foo.name, "foo")
        XCTAssertEqual(signature.$bar.name, "bar")
        XCTAssertEqual(signature.$baz.name, "baz")
        context.console.output("Foo: \(signature.foo) Bar: \(signature.bar ?? "nil")".consoleText(.info))
    }
}

final class StrictCommand: Command {
    struct Signature: CommandSignature {
        @Argument(name: "number")
        var number: Int
        
        @Argument(name: "bool")
        var bool: Bool
        
        init() {}
    }
    var help: String {
        "I error if you pass in bad values"
    }

    func run(using context: CommandContext, signature: Signature) throws {
        print("Done!")
    }
}

final class TestConsole: Console {
    let _testInputQueue: NIOLockedValueBox<[String]> = NIOLockedValueBox([])
    
    var testInputQueue: [String] {
        get { self._testInputQueue.withLockedValue { $0 } }
        set { self._testInputQueue.withLockedValue { $0 = newValue } }
    }
    
    let _testOutputQueue: NIOLockedValueBox<[String]> = NIOLockedValueBox([])
    var testOutputQueue: [String] {
        get { self._testOutputQueue.withLockedValue { $0 } }
        set { self._testOutputQueue.withLockedValue { $0 = newValue } }
    }
    
    let _userInfo: NIOLockedValueBox<[AnySendableHashable: any Sendable]> = NIOLockedValueBox([:])
    var userInfo: [AnySendableHashable: any Sendable] {
        get { self._userInfo.withLockedValue { $0 } }
        set { self._userInfo.withLockedValue { $0 = newValue } }
    }

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

    func report(error: String, newLine: Bool) {}

    func clear(_ type: ConsoleClear) {}

    var size: (width: Int, height: Int) { (width: 0, height: 0) }
}

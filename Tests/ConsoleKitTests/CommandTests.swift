import ConsoleKit
import XCTest

class CommandTests: XCTestCase {
    func testHelp() throws {
        let console = TestConsole()
        let group = TestGroup()
        var input = CommandInput(arguments: ["vapor", "sub", "test", "--help"])
        try console.run(group, input: &input)
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Usage: vapor sub test <foo> [--bar,-b]\u{20}

        This is a test command

        Arguments:
          foo A foo is required
              An error will occur if none exists

        Options:
          bar Add a bar if you so desire
              Try passing it

        """)
    }

    func testFlag() throws {
        let console = TestConsole()
        let group = TestGroup()
        var input = CommandInput(arguments: ["vapor", "sub", "test", "foovalue", "--bar", "baz"])
        try console.run(group, input: &input)
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Foo: foovalue Bar: baz

        """)
    }

    func testShortFlag() throws {
        let console = TestConsole()
        let group = TestGroup()
        var input = CommandInput(arguments: ["vapor", "sub", "test", "foovalue", "-b", "baz"])
        try console.run(group, input: &input)
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Foo: foovalue Bar: baz

        """)
    }

    func testShortFlagNeedsToMatchExactly() throws {
        var input = CommandInput(arguments: ["vapor", "sub", "test", "-x", "exact", "-y_not_exact", "not_exact"])
        XCTAssertEqual(try input.parse(option: Option<String>(name: "xShort", short: "x", type: .value)), "exact")
        XCTAssertNil(try input.parse(option: Option<String>(name: "yShort", short: "y", type: .value)))
    }

    func testDeprecatedFlag() throws {
        let console = TestConsole()
        let group = TestGroup()
        var input = CommandInput(arguments: ["vapor", "sub", "test", "foovalue", "--bar=baz"])
        try console.run(group, input: &input)
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Foo: foovalue Bar: baz

        """)
    }

    func testStrictCommand() throws {
        let console = TestConsole()
        let command = StrictCommand()

        var input = CommandInput(arguments: ["vapor", "3", "true"])
        try console.run(command, input: &input)

        input = CommandInput(arguments: ["vapor", "e", "true"])
        try XCTAssertThrowsError(console.run(command, input: &input))

        input = CommandInput(arguments: ["vapor", "e", "nope"])
        try XCTAssertThrowsError(console.run(command, input: &input))
    }

    func testDynamicAccess() throws {
        #if swift(>=5.1)
        struct DynamicCommand: Command {
            struct Signature: CommandSignature {
                let count = Option<Int>(name: "count", type: .value)
                let auth = Argument<Bool>(name: "auth")
            }
            static let strict = true

            var signature: DynamicCommand.Signature = Signature()
            var help: String? = ""

            func run(using context: CommandContext<DynamicCommand>) throws {
                XCTAssertEqual(context.options.count, 42)
                XCTAssertEqual(context.arguments.auth, true)
            }
        }

        let console = TestConsole()
        let command = DynamicCommand()
        var input = CommandInput(arguments: ["vapor", "true", "--count", "42"])
        try console.run(command, input: &input)
        #endif
    }
}

@testable import ConsoleKit
import XCTest

class CommandTests: XCTestCase {
    func testHelp() throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor", "sub", "test", "--help"])
        try console.run(group, input: input)
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
        let input = CommandInput(arguments: ["vapor", "sub", "test", "foovalue", "--bar", "baz"])
        try console.run(group, input: input)
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Foo: foovalue Bar: baz

        """)
    }

    func testShortFlag() throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor", "sub", "test", "foovalue", "-b", "baz"])
        try console.run(group, input: input)
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Foo: foovalue Bar: baz

        """)
    }

    func testShortFlagNeedsToMatchExactly() throws {
        struct Signature: CommandSignature {
            @Option(name: "x-short", short: "x")
            var xShort: String
            
            @Option(name: "y-short", short: "y")
            var yShort: String
            
            init() { }
        }
        var input = CommandInput(arguments: ["vapor", "sub", "test", "-x", "exact", "-y_not_exact", "not_exact"])
        let signature = try Signature(from: &input)
        XCTAssertEqual(signature.xShort, "exact")
        XCTAssertNil(signature.yShort)
    }

    func testStrictCommand() throws {
        let console = TestConsole()
        let command = StrictCommand()

        var input = CommandInput(arguments: ["vapor", "3", "true"])
        try console.run(command, input: input)

        input = CommandInput(arguments: ["vapor", "e", "true"])
        try XCTAssertThrowsError(console.run(command, input: input))

        input = CommandInput(arguments: ["vapor", "e", "nope"])
        try XCTAssertThrowsError(console.run(command, input: input))
    }

    func testDynamicAccess() throws {
        struct DynamicCommand: Command {
            struct Signature: CommandSignature {
                @Option(name: "count")
                var count: Int?
                
                @Argument(name: "auth")
                var auth: Bool
                
                init() { }
            }
            var help: String = ""

            func run(using context: CommandContext, signature: Signature) throws {
                XCTAssertEqual(signature.count, 42)
                XCTAssertEqual(signature.auth, true)
            }
        }

        let console = TestConsole()
        let command = DynamicCommand()
        let input = CommandInput(arguments: ["vapor", "true", "--count", "42"])
        try console.run(command, input: input)
    }
}

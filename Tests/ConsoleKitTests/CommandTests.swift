@testable import ConsoleKit
import XCTest

class CommandTests: XCTestCase {
    func testBaseHelp() throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor", "--help"])
        try console.run(group, input: input)
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Usage: vapor <command>

        This is a test grouping!

        Commands:
           sub This is a test sub grouping!
          test This is a test command
        
        Use `vapor <command> [--help,-h]` for more information on a command.
        
        """)
    }

    func testHelp() throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor", "sub", "test", "--help"])
        try console.run(group, input: input)
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Usage: vapor sub test <foo> [--bar,-b] [--baz,-B]\u{20}

        This is a test command

        Arguments:
          foo A foo is required
              An error will occur if none exists

        Options:
          bar Add a bar if you so desire
              Try passing it

        Flags:
          baz Add a baz if you so desire
              It's just a flag

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

    func testDeprecatedSyntax() throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor", "sub", "test", "foovalue", "--bar=baz"])
        do {
            try console.run(group, input: input)
            XCTFail("Should have failed")
        } catch {
            // Pass
            print(error)
        }
    }

    func testShortFlagNeedsToMatchExactly() throws {
        struct Signature: CommandSignature {
            @Option(name: "x-short", short: "x")
            var xShort: String?
            
            @Option(name: "y-short", short: "y")
            var yShort: String?
            
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
        struct DynamicCommand: AnyCommand {
            var help: String = ""

            func run(using context: inout CommandContext) throws {
                XCTAssertEqual(context.input.arguments, ["true", "--count", "42"])
            }
        }

        let console = TestConsole()
        let command = DynamicCommand()
        let input = CommandInput(arguments: ["vapor", "true", "--count", "42"])
        try console.run(command, input: input)
    }

    func testOptionUsed() throws {
        struct OptionInitialized: Command {
            struct Signature: CommandSignature {
                @Option(name: "option") var option: String?
                @Option(name: "str") var str: String?
            }

            var help: String = ""
            var assertion: @Sendable (Signature) -> ()

            func run(using context: CommandContext, signature: OptionInitialized.Signature) throws {
                assertion(signature)
            }
        }

        let console = TestConsole()

        try console.run(OptionInitialized(assertion: { 
            XCTAssertEqual($0.option, "true") 
            XCTAssertNil($0.str) 
        }), input: CommandInput(arguments: ["vapor", "--option", "true"]))
        try console.run(OptionInitialized(assertion: { 
            XCTAssertNil($0.option) 
            XCTAssertEqual($0.str, "HelloWorld")
        }), input: CommandInput(arguments: ["vapor", "--str", "HelloWorld"]))
        try console.run(OptionInitialized(assertion: { 
            XCTAssertEqual($0.option, "--str") 
            XCTAssertNil($0.str) 
        }), input: CommandInput(arguments: ["vapor", "--option", "\\--str"]))
    }
}

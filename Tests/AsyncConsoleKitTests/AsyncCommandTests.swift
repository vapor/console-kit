@testable import ConsoleKit
import XCTest

final class AsyncCommandTests: XCTestCase {
    func testBaseHelp() async throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor", "--help"])
        try await console.run(group, input: input)
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Usage: vapor <command>

        This is a test grouping!

        Commands:
           sub This is a test sub grouping!
          test This is a test command
        
        Use `vapor <command> [--help,-h]` for more information on a command.
        
        """)
    }

    func testHelp() async throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor", "sub", "test", "--help"])
        try await console.run(group, input: input)
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

    func testFlag() async throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor", "sub", "test", "foovalue", "--bar", "baz"])
        try await console.run(group, input: input)
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Foo: foovalue Bar: baz

        """)
    }

    func testShortFlag() async throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor", "sub", "test", "foovalue", "-b", "baz"])
        try await console.run(group, input: input)
        XCTAssertEqual(console.testOutputQueue.reversed().joined(separator: ""), """
        Foo: foovalue Bar: baz

        """)
    }

    func testDeprecatedSyntax() async throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor", "sub", "test", "foovalue", "--bar=baz"])
        do {
            try await console.run(group, input: input)
            XCTFail("Should have failed")
        } catch {
            // Pass
            print(error)
        }
    }

    func testShortFlagNeedsToMatchExactly() async throws {
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

    func testStrictCommand() async throws {
        let console = TestConsole()
        let command = StrictCommand()

        var input = CommandInput(arguments: ["vapor", "3", "true"])
        try await console.run(command, input: input)

        input = CommandInput(arguments: ["vapor", "e", "true"])
        let result: Void? = try? await console.run(command, input: input)
        XCTAssertNil(result)
        
        input = CommandInput(arguments: ["vapor", "e", "nope"])
        let otherResult: Void? = try? await console.run(command, input: input)
        XCTAssertNil(otherResult)
    }

    func testDynamicAccess() async throws {
        struct DynamicCommand: AnyAsyncCommand {
            var help: String = ""

            func run(using context: inout CommandContext) throws {
                XCTAssertEqual(context.input.arguments, ["true", "--count", "42"])
            }
        }

        let console = TestConsole()
        let command = DynamicCommand()
        let input = CommandInput(arguments: ["vapor", "true", "--count", "42"])
        try await console.run(command, input: input)
    }

    func testOptionUsed() async throws {
        struct OptionInitialized: AsyncCommand {
            struct Signature: CommandSignature {
                @Option(name: "option") var option: String?
                @Option(name: "str") var str: String?
            }

            var help: String = ""
            var assertion: @Sendable (Signature) -> ()

            func run(using context: CommandContext, signature: OptionInitialized.Signature) async throws {
                assertion(signature)
            }
        }

        let console = TestConsole()

        try await console.run(OptionInitialized(assertion: {
            XCTAssertEqual($0.option, "true")
            XCTAssertNil($0.str)
        }), input: CommandInput(arguments: ["vapor", "--option", "true"]))
        try await console.run(OptionInitialized(assertion: {
            XCTAssertNil($0.option)
            XCTAssertEqual($0.str, "HelloWorld")
        }), input: CommandInput(arguments: ["vapor", "--str", "HelloWorld"]))
        try await console.run(OptionInitialized(assertion: {
            XCTAssertEqual($0.option, "--str")
            XCTAssertNil($0.str)
        }), input: CommandInput(arguments: ["vapor", "--option", "\\--str"]))
    }
}

@testable import ConsoleKitCommands
import XCTest

class CommandErrorTests: XCTestCase {
    func testMissingCommand() throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor"])
        XCTAssertThrowsError(try console.run(group, input: input), "Missing command is supposed to throw") { error in
            guard let commandError = error as? CommandError else {
                return XCTFail("Expected `CommandError` error, got \(type(of: error)).")
            }
            XCTAssertEqual(commandError, .missingCommand, "Expected `.missingCommand` error, got \(String(reflecting: error)).")
            XCTAssertEqual(commandError.description, "Missing command")
        }
    }
    
    func testUnknownCommandWithSuggestion() throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor", "sup"])
        XCTAssertThrowsError(try console.run(group, input: input), "Unknown command is supposed to throw") { error in
            guard let commandError = error as? CommandError else {
                return XCTFail("Expected `CommandError` error, got \(type(of: error)).")
            }
            XCTAssertEqual(commandError, .unknownCommand("sup", available: ["sub", "test"]), "Expected `.unknownCommand` error, got \(String(reflecting: error)).")
            XCTAssertEqual(commandError.description, """
            Unknown command `sup`

            Did you mean this?

            \tsub
            """)
        }
    }
    
    func testUnknownCommandWithoutSuggestion() throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor", "desoxyribonucleic-acid"])
        XCTAssertThrowsError(try console.run(group, input: input), "Unknown command is supposed to throw") { error in
            guard let commandError = error as? CommandError else {
                return XCTFail("Expected `CommandError` error, got \(type(of: error)).")
            }
            XCTAssertEqual(commandError, .unknownCommand("desoxyribonucleic-acid", available: ["sub", "test"]), "Expected `.unknownCommand` error, got \(String(reflecting: error)).")
            XCTAssertEqual(commandError.description, """
            Unknown command `desoxyribonucleic-acid`
            """)
        }
    }
    
    func testCommandWithMissingRequiredArgument() throws {
        let console = TestConsole()
        let command = StrictCommand()

        var input = CommandInput(arguments: ["vapor", "3", "true"])
        try console.run(command, input: input)

        input = CommandInput(arguments: ["vapor"])
        try XCTAssertThrowsError(console.run(command, input: input))
        XCTAssertThrowsError(try console.run(command, input: input), "Missing argument is supposed to throw") { error in
            guard let commandError = error as? CommandError else {
                return XCTFail("Expected `CommandError` error, got \(type(of: error)).")
            }
            XCTAssertEqual(commandError, .missingRequiredArgument("number"), "Expected `.missingRequiredArgument` error, got \(String(reflecting: error)).")
            XCTAssertEqual(commandError.description, "Missing required argument: number")
        }
    }
    
    func testCommandWithInvalidArgumentType() throws {
        let console = TestConsole()
        let command = StrictCommand()

        var input = CommandInput(arguments: ["vapor", "3", "true"])
        try console.run(command, input: input)

        input = CommandInput(arguments: ["vapor", "e", "true"])
        try XCTAssertThrowsError(console.run(command, input: input))
        XCTAssertThrowsError(try console.run(command, input: input), "Invalid argument is supposed to throw") { error in
            guard let commandError = error as? CommandError else {
                return XCTFail("Expected `CommandError` error, got \(type(of: error)).")
            }
            XCTAssertEqual(commandError, .invalidArgumentType("number", type: Int.self), "Expected `.invalidArgumentType` error, got \(String(reflecting: error)).")
            XCTAssertEqual(commandError.description, "Could not convert argument for `number` to Int")
        }
    }
    
    func testCommandWithInvalidOptionType() throws {
        final class IntOptionCommand: Command {
            struct Signature: CommandSignature {
                @Option(name: "bar", short: "b", help: "")
                var bar: Int?
                init() { }
            }
            let help: String = "This is a test command"
            func run(using context: CommandContext, signature: Signature) throws {}
        }
        
        let console = TestConsole()
        let command = IntOptionCommand()
        
        var input = CommandInput(arguments: ["vapor", "--bar", "3"])
        try console.run(command, input: input)
        
        input = CommandInput(arguments: ["vapor", "--bar", "a"])
        try XCTAssertThrowsError(console.run(command, input: input))
        XCTAssertThrowsError(try console.run(command, input: input), "Invalid argument is supposed to throw") { error in
            guard let commandError = error as? CommandError else {
                return XCTFail("Expected `CommandError` error, got \(type(of: error)).")
            }
            XCTAssertEqual(commandError, .invalidOptionType("bar", type: Int.self), "Expected `.invalidOptionType` error, got \(String(reflecting: error)).")
            XCTAssertEqual(commandError.description, "Could not convert option for `bar` to Int")
        }
    }
    
    func testLevenshteinDistance() {
        XCTAssertEqual("".levenshteinDistance(to: "hi"), 2)
        XCTAssertEqual("hi".levenshteinDistance(to: ""), 2)
        XCTAssertEqual("hi".levenshteinDistance(to: "hi"), 0)
        XCTAssertEqual("hi".levenshteinDistance(to: "ho"), 1)
        XCTAssertEqual("hello".levenshteinDistance(to: "world"), 4)
        XCTAssertEqual(
            "There are only two hard problems in computer science"
            .levenshteinDistance(to: "Naming things, cache invalidation, and off-by-one errors"),
            50
        )
    }
}

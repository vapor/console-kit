@testable import ConsoleKitCommands
import XCTest

final class AsyncCommandErrorTests: XCTestCase {
    func testMissingCommand() async throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor"])
        do {
            try await console.run(group, input: input)
        } catch {
            guard let commandError = error as? CommandError else {
                return XCTFail("Expected `CommandError` error, got \(type(of: error)).")
            }
            XCTAssertEqual(commandError, .missingCommand, "Expected `.missingCommand` error, got \(String(reflecting: error)).")
            XCTAssertEqual(commandError.description, "Missing command")
            return
        }
        
        XCTFail("Missing command is supposed to throw")
    }
    
    func testUnknownCommandWithSuggestion() async throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor", "sup"])
        
        do {
            try await console.run(group, input: input)
        } catch {
            guard let commandError = error as? CommandError else {
                return XCTFail("Expected `CommandError` error, got \(type(of: error)).")
            }
            XCTAssertEqual(commandError, .unknownCommand("sup", available: ["sub", "test"]), "Expected `.unknownCommand` error, got \(String(reflecting: error)).")
            XCTAssertEqual(commandError.description, """
            Unknown command `sup`

            Did you mean this?

            \tsub
            """)
            
            return
        }
        
        XCTFail("Unknown command is supposed to throw")
    }
    
    func testUnknownCommandWithoutSuggestion() async throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor", "desoxyribonucleic-acid"])
        do {
            try await console.run(group, input: input)
        } catch {
            guard let commandError = error as? CommandError else {
                return XCTFail("Expected `CommandError` error, got \(type(of: error)).")
            }
            XCTAssertEqual(commandError, .unknownCommand("desoxyribonucleic-acid", available: ["sub", "test"]), "Expected `.unknownCommand` error, got \(String(reflecting: error)).")
            XCTAssertEqual(commandError.description, """
            Unknown command `desoxyribonucleic-acid`
            """)
            return
        }
        
        XCTFail("Unknown command is supposed to throw")
    }
    
    func testCommandWithMissingRequiredArgument() async throws {
        let console = TestConsole()
        let command = StrictCommand()

        var input = CommandInput(arguments: ["vapor", "3", "true"])
        try await console.run(command, input: input)

        input = CommandInput(arguments: ["vapor"])
        
        do {
            try await console.run(command, input: input)
        } catch {
            guard let commandError = error as? CommandError else {
                return XCTFail("Expected `CommandError` error, got \(type(of: error)).")
            }
            XCTAssertEqual(commandError, .missingRequiredArgument("number"), "Expected `.missingRequiredArgument` error, got \(String(reflecting: error)).")
            XCTAssertEqual(commandError.description, "Missing required argument: number")
            return
        }
        
        XCTFail("Missing argument is supposed to throw")
    }
    
    func testCommandWithInvalidArgumentType() async throws {
        let console = TestConsole()
        let command = StrictCommand()

        var input = CommandInput(arguments: ["vapor", "3", "true"])
        try await console.run(command, input: input)

        input = CommandInput(arguments: ["vapor", "e", "true"])
        do {
            try await console.run(command, input: input)
        } catch {
            guard let commandError = error as? CommandError else {
                return XCTFail("Expected `CommandError` error, got \(type(of: error)).")
            }
            XCTAssertEqual(commandError, .invalidArgumentType("number", type: Int.self), "Expected `.invalidArgumentType` error, got \(String(reflecting: error)).")
            XCTAssertEqual(commandError.description, "Could not convert argument for `number` to Int")
            return
        }
        
        XCTFail("Invalid argument is supposed to throw")
    }
    
    func testCommandWithInvalidOptionType() async throws {
        final class IntOptionCommand: AsyncCommand {
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
        try await console.run(command, input: input)
        
        input = CommandInput(arguments: ["vapor", "--bar", "a"])
        do {
            try await console.run(command, input: input)
        } catch {
            guard let commandError = error as? CommandError else {
                return XCTFail("Expected `CommandError` error, got \(type(of: error)).")
            }
            XCTAssertEqual(commandError, .invalidOptionType("bar", type: Int.self), "Expected `.invalidOptionType` error, got \(String(reflecting: error)).")
            XCTAssertEqual(commandError.description, "Could not convert option for `bar` to Int")
            return
        }
        
        XCTFail("Invalid argument is supposed to throw")
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

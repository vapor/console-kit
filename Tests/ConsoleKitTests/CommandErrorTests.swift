@testable import ConsoleKit
import XCTest

class CommandErrorTests: XCTestCase {
    func testMissingCommand() throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor"])
        XCTAssertThrowsError(try console.run(group, input: input), "Missing command is supposed to throw") { error in
            guard case .missingCommand = error as? CommandError else {
                return XCTFail("Expected `.missingCommand` error, got \(error).")
            }
            XCTAssertEqual((error as! CommandError).description, "Error: Missing command")
        }
    }
    
    func testUnknownCommandWithSuggestion() throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor", "sup"])
        XCTAssertThrowsError(try console.run(group, input: input), "Unknown command is supposed to throw") { error in
            guard case .unknownCommand = error as? CommandError else {
                return XCTFail("Expected `.unknownCommand` error, got \(error).")
            }
            XCTAssertEqual((error as! CommandError).description, """
            Error: Unknown command `sup`

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
            guard case .unknownCommand = error as? CommandError else {
                return XCTFail("Expected `.unknownCommand` error, got \(error).")
            }
            XCTAssertEqual((error as! CommandError).description, """
            Error: Unknown command `desoxyribonucleic-acid`
            """)
        }
    }
    
    func testCommandWithMissingRequiredArgument() throws {
        // TODO: Implement
    }
    
    func testCommandWithInvalidArgumentType() throws {
        let console = TestConsole()
        let command = StrictCommand()

        var input = CommandInput(arguments: ["vapor", "3", "true"])
        try console.run(command, input: input)

        input = CommandInput(arguments: ["vapor", "e", "true"])
        try XCTAssertThrowsError(console.run(command, input: input))
        XCTAssertThrowsError(try console.run(command, input: input), "Missing command is supposed to throw") { error in
            guard case .invalidArgumentType = error as? CommandError else {
                return XCTFail("Expected `.invalidArgumentType` error, got \(error).")
            }
            XCTAssertEqual((error as! CommandError).description, "Error: Could not convert argument for number to Int")
        }
    }
    
    func testCommandWithInvalidOptionType() throws {
        // TODO: Implement
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

@testable import ConsoleKit
import XCTest

class CommandErrorTests: XCTestCase {
    func testUnknownWithSuggestionCommand() throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor", "sup"])
        XCTAssertThrowsError(try console.run(group, input: input), "Unknown command is supposed to throw") { error in
            XCTAssertEqual((error as! CommandError).description, """
            Error: Unknown command `sup`

            Did you mean this?

            \tsub
            """)
        }
    }
    
    func testUnknownWithoutSuggestionCommand() throws {
        let console = TestConsole()
        let group = TestGroup()
        let input = CommandInput(arguments: ["vapor", "desoxyribonucleic-acid"])
        XCTAssertThrowsError(try console.run(group, input: input), "Unknown command is supposed to throw") { error in
            XCTAssertEqual((error as! CommandError).description, """
            Error: Unknown command `desoxyribonucleic-acid`
            """)
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

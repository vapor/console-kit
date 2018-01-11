import XCTest
import Command
import Console

class CommandTests: XCTestCase {
    func testExample() throws {
        let console = Terminal()
        let group = TestGroup()

        var input = CommandInput(arguments: ["vapor", "sub", "test", "--help"])
        try! console.run(group, input: &input)
        print(console.output)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

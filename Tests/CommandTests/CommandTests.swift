import XCTest
import Command
import Console

class CommandTests: XCTestCase {
    func testExample() throws {
        let console = Terminal()
        let group = TestGroup()

        var input = CommandInput(arguments: ["vapor", "sub", "test", "asdf", "--port"])
        do {
            try console.run(group, input: &input)
        } catch {
            XCTFail("\(error)")
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

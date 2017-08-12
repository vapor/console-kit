import XCTest
import Command

class CommandTests: XCTestCase {
    func testExample() throws {
        let console = TestConsole()
        let group = TestGroup()

        try! console.run(.group(group), arguments: ["vapor", "--help"])
        print(console.output)
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}

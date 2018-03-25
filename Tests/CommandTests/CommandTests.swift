import Async
import Command
import Console
import Service
import XCTest

class CommandTests: XCTestCase {
    func testExample() throws {
        let console = Terminal()
        let group = TestGroup()
        let container = BasicContainer(config: .init(), environment: .testing, services: .init(), on: EmbeddedEventLoop())
        var input = CommandInput(arguments: ["vapor", "sub", "test", "--help"])
        try console.run(group, input: &input, on: container).wait()
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

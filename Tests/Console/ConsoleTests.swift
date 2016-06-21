import XCTest

#if os(Linux)
import Glibc
#else
import Darwin
#endif


@testable import Console

class ConsoleTests: XCTestCase {
    static let allTests = [
        ("testAsk", testAsk),
        ("testConfirm", testConfirm),
    ]

    func testAsk() {
        let console = TestConsole()

        let name = "Test Name"
        let question = "What is your name?"

        console.inputBuffer = name

        let response = console.ask(question)

        XCTAssertEqual(response, name)
        XCTAssertEqual(console.outputBuffer, question + "\n>")
    }

    func testConfirm() {
        let console = TestConsole()

        let name = "y"
        let question = "Do you want to continue?"

        console.inputBuffer = name

        let response = console.confirm(question)

        XCTAssertEqual(response, true)
        XCTAssertEqual(console.outputBuffer, question + "\ny/n>")
    }

}

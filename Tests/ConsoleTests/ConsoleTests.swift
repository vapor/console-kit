import XCTest
import Console

class ConsoleTests: XCTestCase {
    func testLoading() throws {
        let console = Terminal()
        let worker = EmbeddedEventLoop()
        let foo = console.loadingBar(title: "Loading")

        DispatchQueue.global().async {
            console.blockingWait(seconds: 2.5)
            foo.succeed()
        }

        try foo.start(on: worker).wait()
    }

    func testProgress() throws {
        let console = Terminal()
        let worker = EmbeddedEventLoop()
        let foo = console.progressBar(title: "Progress")

        DispatchQueue.global().async {
            while true {
                if foo.activity.currentProgress >= 1.0 {
                    foo.succeed()
                    break
                } else {
                    foo.activity.currentProgress += 0.1
                    console.blockingWait(seconds: 0.1)
                }
            }
        }

        try foo.start(on: worker).wait()
    }

    func testAsk() throws {
        let console = TestConsole()

        let name = "Test Name"
        let question = "What is your name?"

        console.input = name

        let response = console.ask(question)

        XCTAssertEqual(response, name)
        XCTAssertEqual(console.output, question + "\n> ")
    }

    func testConfirm() throws {
        let console = TestConsole()

        let name = "y"
        let question = "Do you want to continue?"

        console.input = name

        let response = console.confirm(question)

        XCTAssertEqual(response, true)
        XCTAssertEqual(console.output, question + "\ny/n> ")
    }

    static let allTests = [
        ("testAsk", testAsk),
        ("testConfirm", testConfirm),
    ]
}

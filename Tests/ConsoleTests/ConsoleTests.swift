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

    func testCustomIndicator()throws {
        let console = Terminal()
        let worker = EmbeddedEventLoop()
        
        let indicator = console.activity(frames: ["⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"])
        
        DispatchQueue.global().async {
            console.blockingWait(seconds: 3)
            indicator.succeed()
        }
        
        try indicator.start(on: worker).wait()
    }
    
    func testEphemeral() {
        // for some reason, piping through test output doesn't work correctly
        // but this code works great if running directly in an executable

        // added here anyway to verify that the code snippet in doc blocks actually compiles
        let console = Terminal()
        console.print("a")
        console.pushEphemeral()
        console.print("b")
        console.print("c")
        console.pushEphemeral()
        console.print("d")
        console.print("e")
        console.print("f")
        console.blockingWait(seconds: 1)
        console.popEphemeral() // removes "d", "e", and "f" lines
        console.print("g")
        console.blockingWait(seconds: 1)
        console.popEphemeral() // removes "b", "c", and "g" lines
        // just "a" has been printed now
    }

    func testAsk() throws {
        let console = TestConsole()

        let name = "Test Name"
        let question = "What is your name?"

        console.input = name

        let response = console.ask(question.consoleText(.plain))

        XCTAssertEqual(response, name)
        XCTAssertEqual(console.output, question + "\n> ")
    }

    func testConfirm() throws {
        let console = TestConsole()

        let name = "y"
        let question = "Do you want to continue?"

        console.input = name

        let response = console.confirm(question.consoleText(.info))

        XCTAssertEqual(response, true)
        XCTAssertEqual(console.output, question + "\ny/n> ")
    }

    static let allTests = [
        ("testAsk", testAsk),
        ("testConfirm", testConfirm),
    ]
}

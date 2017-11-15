import XCTest

import libc

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
        XCTAssertEqual(console.outputBuffer, question + "\n> ")
    }

    func testConfirm() {
        let console = TestConsole()

        let name = "y"
        let question = "Do you want to continue?"

        console.inputBuffer = name

        let response = console.confirm(question)

        XCTAssertEqual(response, true)
        XCTAssertEqual(console.outputBuffer, question + "\ny/n> ")
    }

    func testCenter() {
        let console = TestConsole()
        let input = ["1", "222222", "3"]
        let output = console.center(input)
        XCTAssertEqual(output,
           ["                                     1",
            "                                     222222",
            "                                     3"
            ]
        )
    }

    #if swift(>=4)
    func testProgressBar() {
        let console = TestConsole()
        let progressBar = console.progressBar(title: "copying")
        let cycles = 3
        for i in 0 ... cycles {
            progressBar.progress = Double(i) / Double(cycles)
        }
        XCTAssertEqual(console.outputBuffer, """
            copying [=                        ] 0%
            copying [=========                ] 33%
            copying [=================        ] 66%
            copying [=========================] 100%
            """ + "\n")
    }
    #endif
}

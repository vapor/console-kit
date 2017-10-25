import XCTest

@testable import Console


private func loadingBarConstructor() -> (TestConsole, LoadingBar) {
    let console = TestConsole()
    let bar = LoadingBar(console: console, title: "title", width: 10,
                         barStyle: ConsoleStyle.info,
                         titleStyle: ConsoleStyle.info, animated: false)
    return (console, bar)
}

class LoadingBarTests: XCTestCase {

    static let allTests = [
        ("testUpdate", testUpdate),
        ("testFail", testFail),
        ]

    func testUpdate() {
        var expectedOutput = ""
        let (console, bar) = loadingBarConstructor()
        XCTAssertEqual(console.outputBuffer, "")
        bar.update()
        expectedOutput += "title [ •        ]\n"
        XCTAssertEqual(console.outputBuffer,
                       expectedOutput
        )
        bar.update()
        expectedOutput += "title [  •       ]\n"
        XCTAssertEqual(console.outputBuffer,
                       expectedOutput
        )

    }

    func testFail() {
        let (console, bar) = loadingBarConstructor()
        bar.fail()
        let expectedOutput = "title [Failed]\n"
        XCTAssertEqual(console.outputBuffer,
                       expectedOutput
        )
    }
}


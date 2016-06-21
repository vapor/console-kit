import XCTest

#if os(Linux)
import Glibc
#else
import Darwin
#endif


@testable import Console

class ConsoleTests: XCTestCase {
    static let allTests = [
        ("testExample", testExample)
    ]

    func testExample() {
        let console = Terminal()

        console.info("")

        let progressBar = console.progressBar(title: "Fake download")

        for i in 0 ... 3 {
            if i != 0 {
                sleep(1)
            }
            let progress = Double(i) / 4.0
            progressBar.progress = progress
        }

        //progressBar.fail("Download failed")
        progressBar.finish()

        let loadingBar = console.loadingBar(title: "Fake loading")
        loadingBar.start()

        sleep(3)

        loadingBar.fail()
//        loadingBar.finish()

        let result = console.ask("What's your name?")
        console.info("Your name is: \(result)")



        let result2 = console.confirm("Do you want to continue?")
        console.info(result2.description)

    }

}

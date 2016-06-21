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

        console.info("Simulating download...")


        for i in 0 ... 3 {
            sleep(1)
            let progress = Double(i) / 3.0
            console.progress(progress)
        }

        console.progress(0.75, failed: true)

        console.error("Download failed")

        let loader = console.loader()

        sleep(3)

        loader.stop()

        let result = console.ask("What's your name?")
        console.info("Your name is: \(result)")



        let result2 = console.confirm("Do you want to continue?")
        console.info(result2.description)

    }

}

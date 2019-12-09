import ConsoleKit
import Logging
import XCTest

final class ConsoleLoggerTests: XCTestCase {
    func testLogHandlerCheck() {
        let console = TestConsole()
        var logger1 = Logger(label: "codes.vapor.console.1") { label in
            ConsoleLogger(label: label, console: console)
        }
        logger1.logLevel = .debug
        logger1[metadataKey: "only-on"] = "first"
        
        var logger2 = logger1
        logger2.logLevel = .error
        logger2[metadataKey: "only-on"] = "second"
        
        XCTAssertEqual(.debug, logger1.logLevel)
        XCTAssertEqual(.error, logger2.logLevel)
        XCTAssertEqual("first", logger1[metadataKey: "only-on"])
        XCTAssertEqual("second", logger2[metadataKey: "only-on"])
    }
    
    func testLoggingLevels()throws {
        let console = TestConsole()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label, console: console, level: .info)
        }
        let expectedOutput = { (level: String, text: String) -> String in
            return "[ \(level) ] \(text)\n"
        }
        
        logger.trace("trace")
        XCTAssertNil(console.testOutputQueue.first)
        
        logger.debug("debug")
        XCTAssertNil(console.testOutputQueue.first)
        
        logger.info("info")
        XCTAssertEqual(console.testOutputQueue.first, expectedOutput("INFO", "info"))
        
        logger.notice("notice")
        XCTAssertEqual(console.testOutputQueue.first, expectedOutput("NOTICE", "notice"))
        
        logger.warning("warning")
        XCTAssertEqual(console.testOutputQueue.first, expectedOutput("WARNING", "warning"))
        
        logger.error("error")
        XCTAssertEqual(console.testOutputQueue.first, expectedOutput("ERROR", "error"))
        
        logger.critical("critical")
        XCTAssertEqual(console.testOutputQueue.first, expectedOutput("CRITICAL", "critical"))
    }
}

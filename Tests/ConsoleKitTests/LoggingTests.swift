import ConsoleKit
import Logging
import XCTest

final class ConsoleLoggerTests: XCTestCase {
    fileprivate static var bootstrapped = false
    let console = TestConsole()
    
    override func setUp() {
        super.setUp()

        if !ConsoleLoggerTests.bootstrapped {
            LoggingSystem.bootstrap(console: console)
            ConsoleLoggerTests.bootstrapped = true
        }
    }
    
    func testLogHandlerCheck() {
        var logger1 = Logger(label: "first logger")
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
        let logger = Logger(label: "com.vapor.console")
        let expectedOutput = { (level: String, text: String) -> String in
            return "[ \(level) ] \(text)\n"
        }
        
        logger.trace("trace")
        XCTAssertNil(self.console.testOutputQueue.first)
        
        logger.debug("debug")
        XCTAssertNil(self.console.testOutputQueue.first)
        
        logger.info("info")
        XCTAssertEqual(self.console.testOutputQueue.first, expectedOutput("INFO", "info"))
        
        logger.notice("notice")
        XCTAssertEqual(self.console.testOutputQueue.first, expectedOutput("NOTICE", "notice"))
        
        logger.warning("warning")
        XCTAssertEqual(self.console.testOutputQueue.first, expectedOutput("WARNING", "warning"))
        
        logger.error("error")
        XCTAssertEqual(self.console.testOutputQueue.first, expectedOutput("ERROR", "error"))
        
        logger.critical("critical")
        XCTAssertEqual(self.console.testOutputQueue.first, expectedOutput("CRITICAL", "critical"))
    }
}

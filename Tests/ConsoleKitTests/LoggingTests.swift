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
        let expectedOutput = { (level: String, text: String, line: Int) -> String in
            return "[ \(level) ] \(text) (\(#file):\(line))\n"
        }
        
        logger.trace("trace")
        XCTAssertEqual(self.console.testOutputQueue.first, expectedOutput("Trace", "trace", #line - 1))
        
        logger.debug("debug")
        XCTAssertEqual(self.console.testOutputQueue.first, expectedOutput("Debug", "debug", #line - 1))
        
        logger.info("info")
        XCTAssertEqual(self.console.testOutputQueue.first, expectedOutput("Info", "info", #line - 1))
        
        logger.notice("notice")
        XCTAssertEqual(self.console.testOutputQueue.first, expectedOutput("Notice", "notice", #line - 1))
        
        logger.warning("warning")
        XCTAssertEqual(self.console.testOutputQueue.first, expectedOutput("Warning", "warning", #line - 1))
        
        logger.error("error")
        XCTAssertEqual(self.console.testOutputQueue.first, expectedOutput("Error", "error", #line - 1))
        
        logger.critical("critical")
        XCTAssertEqual(self.console.testOutputQueue.first, expectedOutput("Critical", "critical", #line - 1))
    }
}

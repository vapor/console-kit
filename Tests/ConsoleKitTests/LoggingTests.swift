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
    
    func testLoggingLevels() throws {
        let console = TestConsole()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label, console: console, level: .info)
        }

        logger.trace("trace")
        XCTAssertNil(console.testOutputQueue.first)
        
        logger.debug("debug")
        XCTAssertNil(console.testOutputQueue.first)
        
        logger.info("info")
        XCTAssertLog(console, .info, "info")
        
        logger.notice("notice")
        XCTAssertLog(console, .notice, "notice")
        
        logger.warning("warning")
        XCTAssertLog(console, .warning, "warning")
        
        logger.error("error")
        XCTAssertLog(console, .error, "error")
        
        logger.critical("critical")
        XCTAssertLog(console, .critical, "critical")
    }

    func testMetadata() {
        let console = TestConsole()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label, console: console, level: .info, metadata: ["meta": "test"])
        }

        logger.info("info")
        XCTAssertLog(console, .info, "info [meta: test]")
    }

    func testSourceLocation() {
        let console = TestConsole()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label, console: console, level: .debug, sourcePathDelimiter: "ConsoleKitTests")
        }

        logger.debug("debug")
        XCTAssertLog(console, .debug, "debug (LoggingTests.swift:68)")
    }
}

private func XCTAssertLog(_ console: TestConsole, _ level: Logger.Level, _ message: String, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertEqual(console.testOutputQueue.first, "[ \(level.name) ] \(message)\n", file: file, line: line)
}

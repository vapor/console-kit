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
            ConsoleLogger(label: label, console: console, level: .info, metadata: ["meta1": "test1"])
        }

        logger.info("info")
        XCTAssertLog(console, .info, "info [meta1: test1]")

        logger.info("info", metadata: ["meta2": "test2"])
        XCTAssertLog(console, .info, "info [meta1: test1, meta2: test2]")

        logger.info("info", metadata: ["meta1": "overridden"])
        XCTAssertLog(console, .info, "info [meta1: overridden]")
    }

    func testSourceLocation() {
        let console = TestConsole()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label, console: console, level: .debug)
        }

        logger.debug("debug")
        XCTAssertLog(console, .debug, "debug (ConsoleKitTests/LoggingTests.swift:74)")
    }
    
    func testMetadataProviders() {
        let simpleTraceIDMetadataProvider = Logger.MetadataProvider {
            guard let traceID = TraceNamespace.simpleTraceID else {
                return [:]
            }
            return ["simple-trace-id": .string(traceID)]
        }
        let console = TestConsole()
        
        LoggingSystem.bootstrap({ label, metadataProvider in
            ConsoleLogger(label: label, console: console, metadataProvider: metadataProvider)
        }, metadataProvider: simpleTraceIDMetadataProvider)
        
        let logger = Logger(label: "codes.vapor.console")

        TraceNamespace.$simpleTraceID.withValue("1234-5678") {
            logger.debug("debug")
        }
        XCTAssertLog(console, .debug, "debug [simple-trace-id: 1234-5678] (ConsoleKitTests/LoggingTests.swift:94)")
    }
}

private func XCTAssertLog(_ console: TestConsole, _ level: Logger.Level, _ message: String, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(console.testOutputQueue.first, "[ \(level.name) ] \(message)\n", file: (file), line: line)
}

enum TraceNamespace {
    @TaskLocal static var simpleTraceID: String?
}


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

        logger.info("info", metadata: ["meta1": "test1", "meta2": .stringConvertible(CommandError.missingCommand), "meta3": ["hello", "wor\"ld"], "meta4": ["hello": "wor\"ld"]])
        XCTAssertLog(console, .info, #"info [meta1: test1, meta2: Missing command, meta3: [hello, wor"ld], meta4: [hello: wor"ld]]"#)
    }

    func testSourceLocation() {
        let console = TestConsole()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label, console: console, level: .debug)
        }

        logger.debug("debug", line: 1)
        XCTAssertLog(console, .debug, "debug (ConsoleKitTests/LoggingTests.swift:1)")
    }
    
    func testMetadataProviders() {
        let simpleTraceIDMetadataProvider = Logger.MetadataProvider {
            guard let traceID = TraceNamespace.simpleTraceID else {
                return [:]
            }
            return ["simple-trace-id": .string(traceID)]
        }
        let console = TestConsole()
        
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label, console: console, metadataProvider: simpleTraceIDMetadataProvider)
        }

        TraceNamespace.$simpleTraceID.withValue("1234-5678") {
            logger.debug("debug", line: 1)
        }
        XCTAssertLog(console, .debug, "debug [simple-trace-id: 1234-5678] (ConsoleKitTests/LoggingTests.swift:1)")
    }
    
    func testTimestampFragment() {
        let console = TestConsole()
        
        struct ConstantTimestampSource: TimestampSource, @unchecked Sendable {
            let time: tm
            
            func now() -> tm {
                self.time
            }
        }
        
        let logger = Logger(label: "codes.vapor.console") { label in
            var time = tm()
            time.tm_sec = 1
            time.tm_min = 2
            time.tm_hour = 3
            time.tm_mday = 4
            time.tm_mon = 5
            time.tm_year = 100
            
            return ConsoleFragmentLogger(
                fragment: timestampDefaultLoggerFragment(timestampSource: ConstantTimestampSource(time: time)),
                label: label,
                console: console
            )
        }
        
        logger.info("logged", line: 1)
        
        var logged = console.testOutputQueue.first!
        let expect = "2000-06-04T03:02:01"
        XCTAssert(logged.hasPrefix(expect))
        logged.removeFirst(expect.count)
        
        // Remove the timezone, since there doesn't appear to be a good way to mock it with strftime.
        while logged.removeFirst() != " " { }
        
        XCTAssertEqual(logged, "[ \(Logger.Level.info.name) ] logged (ConsoleKitTests/LoggingTests.swift:1)\n")
    }
    
    func testSourceFragment() {
        let console = TestConsole()
        
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleFragmentLogger(
                fragment: LoggerSourceFragment().and(defaultLoggerFragment().separated(" ")),
                label: label,
                console: console
            )
        }
        
        logger.info("logged", line: 1)
        
        XCTAssertEqual(console.testOutputQueue.first, "ConsoleKitTests [ \(Logger.Level.info.name) ] logged (ConsoleKitTests/LoggingTests.swift:1)\n")
    }
}

private func XCTAssertLog(_ console: TestConsole, _ level: Logger.Level, _ message: String, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertEqual(console.testOutputQueue.first ?? "", "[ \(level.name) ] \(message)\n", file: file, line: line)
}

enum TraceNamespace {
    @TaskLocal static var simpleTraceID: String?
}


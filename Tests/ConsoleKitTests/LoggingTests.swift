import ConsoleKit
import Logging
import Testing

#if canImport(Darwin)
import Darwin.C
#elseif canImport(Glibc)
@preconcurrency import Glibc
#elseif canImport(Musl)
@preconcurrency import Musl
#elseif canImport(Android)
@preconcurrency import Android
#elseif os(WASI)
import WASILibc
#elseif os(Windows)
import CRT
#endif

@Suite("ConsoleLogger Tests")
struct ConsoleLoggerTests {
    @Test("Log Handler Check")
    func logHandlerCheck() {
        let console = TestConsole()
        var logger1 = Logger(label: "codes.vapor.console.1") { label in
            ConsoleLogger(label: label, console: console)
        }
        logger1.logLevel = .debug
        logger1[metadataKey: "only-on"] = "first"

        var logger2 = logger1
        logger2.logLevel = .error
        logger2[metadataKey: "only-on"] = "second"

        #expect(.debug == logger1.logLevel)
        #expect(.error == logger2.logLevel)
        #expect("first" == logger1[metadataKey: "only-on"])
        #expect("second" == logger2[metadataKey: "only-on"])
    }

    @Test("Logging Levels")
    func loggingLevels() throws {
        let console = TestConsole()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label, console: console, level: .info)
        }

        logger.trace("trace")
        #expect(console.testOutputQueue.first == nil)

        logger.debug("debug")
        #expect(console.testOutputQueue.first == nil)

        logger.info("info")
        expect(console, logs: .info, message: "info")

        logger.notice("notice")
        expect(console, logs: .notice, message: "notice")

        logger.warning("warning")
        expect(console, logs: .warning, message: "warning")

        logger.error("error")
        expect(console, logs: .error, message: "error")

        logger.critical("critical")
        expect(console, logs: .critical, message: "critical")
    }

    @Test("Metadata")
    func metadata() {
        let console = TestConsole()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label, console: console, level: .info, metadata: ["meta1": "test1"])
        }

        logger.info("info")
        expect(console, logs: .info, message: "info [meta1: test1]")

        logger.info("info", metadata: ["meta2": "test2"])
        expect(console, logs: .info, message: "info [meta1: test1, meta2: test2]")

        logger.info("info", metadata: ["meta1": "overridden"])
        expect(console, logs: .info, message: "info [meta1: overridden]")

        logger.info(
            "info",
            metadata: [
                "meta1": "test1", "meta2": .stringConvertible("Missing command"), "meta3": ["hello", "wor\"ld"],
                "meta4": ["hello": "wor\"ld"],
            ]
        )
        expect(
            console, logs: .info, message: #"info [meta1: test1, meta2: Missing command, meta3: [hello, wor"ld], meta4: [hello: wor"ld]]"#)
    }

    @Test("Source Location")
    func sourceLocation() {
        let console = TestConsole()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label, console: console, level: .debug)
        }

        logger.debug("debug", line: 1)
        expect(console, logs: .debug, message: "debug (ConsoleKitTests/LoggingTests.swift:1)")
    }

    @Test("Metadata Providers")
    func metadataProviders() {
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
        expect(console, logs: .debug, message: "debug [simple-trace-id: 1234-5678] (ConsoleKitTests/LoggingTests.swift:1)")
    }

    @Test("Timestamp Fragment")
    func timestampFragment() {
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

            return ConsoleLogger(
                fragment: timestampDefaultLoggerFragment(timestampSource: ConstantTimestampSource(time: time)),
                label: label,
                console: console
            )
        }

        logger.info("logged", line: 1)

        var logged = console.testOutputQueue.first!
        let expect = "2000-06-04T03:02:01"
        #expect(logged.hasPrefix(expect))
        logged.removeFirst(expect.count)

        // Remove the timezone, since there doesn't appear to be a good way to mock it with strftime.
        while logged.removeFirst() != " " {}

        #expect(logged == "[ \(Logger.Level.info.name) ] logged (ConsoleKitTests/LoggingTests.swift:1)\n")
    }

    @Test("Source Fragment")
    func sourceFragment() {
        let console = TestConsole()

        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(
                fragment: LoggerSourceFragment().and(defaultLoggerFragment.separated(" ")),
                label: label,
                console: console
            )
        }

        logger.info("logged", line: 1)

        #expect(
            console.testOutputQueue.first == "ConsoleKitTests [ \(Logger.Level.info.name) ] logged (ConsoleKitTests/LoggingTests.swift:1)\n"
        )
    }
}

private func expect(_ console: TestConsole, logs level: Logger.Level, message: String, sourceLocation: SourceLocation = #_sourceLocation) {
    #expect(console.testOutputQueue.first ?? "" == "[ \(level.name) ] \(message)\n", sourceLocation: sourceLocation)
}

enum TraceNamespace {
    @TaskLocal static var simpleTraceID: String?
}

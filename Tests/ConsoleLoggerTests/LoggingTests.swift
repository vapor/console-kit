import Configuration
import ConsoleLogger
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
        var logger1 = Logger(label: "codes.vapor.console.1") { label in
            ConsoleLogger(label: label)
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
        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(printer: printer, label: label, level: .info)
        }

        logger.trace("trace")
        #expect(printer.testOutputQueue.first == nil)

        logger.debug("debug")
        #expect(printer.testOutputQueue.first == nil)

        logger.info("info")
        expect(printer: printer, logs: .info, message: "info")

        logger.notice("notice")
        expect(printer: printer, logs: .notice, message: "notice")

        logger.warning("warning")
        expect(printer: printer, logs: .warning, message: "warning")

        logger.error("error")
        expect(printer: printer, logs: .error, message: "error")

        logger.critical("critical")
        expect(printer: printer, logs: .critical, message: "critical")
    }

    @Test("Metadata")
    func metadata() {
        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(printer: printer, label: label, level: .info, metadata: ["meta1": "test1"])
        }

        logger.info("info")
        expect(printer: printer, logs: .info, message: "info [meta1: test1]")

        logger.info("info", metadata: ["meta2": "test2"])
        expect(printer: printer, logs: .info, message: "info [meta1: test1, meta2: test2]")

        logger.info("info", metadata: ["meta1": "overridden"])
        expect(printer: printer, logs: .info, message: "info [meta1: overridden]")

        logger.info(
            "info",
            metadata: [
                "meta1": "test1", "meta2": .stringConvertible("Missing command"), "meta3": ["hello", "wor\"ld"],
                "meta4": ["hello": "wor\"ld"],
            ]
        )
        expect(
            printer: printer,
            logs: .info,
            message: #"info [meta1: test1, meta2: "Missing command", meta3: [hello, wor"ld], meta4: [hello: wor"ld]]"#
        )
    }

    @Test("Source Location")
    func sourceLocation() {
        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(printer: printer, label: label, level: .debug)
        }

        logger.debug("debug", line: 1)
        expect(printer: printer, logs: .debug, message: "debug (ConsoleLoggerTests/LoggingTests.swift:1)")
    }

    @Test("Metadata Providers")
    func metadataProviders() {
        let simpleTraceIDMetadataProvider = Logger.MetadataProvider {
            guard let traceID = TraceNamespace.simpleTraceID else {
                return [:]
            }
            return ["simple-trace-id": .string(traceID)]
        }

        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(printer: printer, label: label, metadataProvider: simpleTraceIDMetadataProvider)
        }

        TraceNamespace.$simpleTraceID.withValue("1234-5678") {
            logger.debug("debug", line: 1)
        }
        expect(printer: printer, logs: .debug, message: "debug [simple-trace-id: 1234-5678] (ConsoleLoggerTests/LoggingTests.swift:1)")
    }

    @Test("Timestamp Fragment")
    func timestampFragment() {
        struct ConstantTimestampSource: TimestampSource, @unchecked Sendable {
            let time: tm

            func now() -> tm {
                self.time
            }
        }

        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            var time = tm()
            time.tm_sec = 1
            time.tm_min = 2
            time.tm_hour = 3
            time.tm_mday = 4
            time.tm_mon = 5
            time.tm_year = 100

            return ConsoleLogger(
                fragment: .timestampDefault(timestampSource: ConstantTimestampSource(time: time)),
                printer: printer,
                label: label
            )
        }

        logger.info("logged", line: 1)

        var logged = printer.testOutputQueue.first!
        let expect = "2000-06-04T03:02:01"
        #expect(logged.hasPrefix(expect))
        logged.removeFirst(expect.count)

        // Remove the timezone, since there doesn't appear to be a good way to mock it with strftime.
        while logged.removeFirst() != " " {}

        #expect(logged == "[ \(Logger.Level.info.name) ] logged (ConsoleLoggerTests/LoggingTests.swift:1)")
    }

    @Test("Source Fragment")
    func sourceFragment() {
        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            return ConsoleLogger(
                fragment: LoggerSourceFragment().and(.default.separated(" ")),
                printer: printer,
                label: label
            )
        }

        logger.info("logged", line: 1)

        #expect(
            printer.testOutputQueue.first
                == "ConsoleLoggerTests [ \(Logger.Level.info.name) ] logged (ConsoleLoggerTests/LoggingTests.swift:1)"
        )
    }

    @Test("Log Level from ConfigReader", .serialized, arguments: Logger.Level.allCases)
    func logLevelFromConfigReader(level: Logger.Level) {
        let config = ConfigReader(provider: InMemoryProvider(values: ["log.level": .init(stringLiteral: level.rawValue)]))
        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(printer: printer, label: label, config: config)
        }
        logger.log(level: level, "logged", line: 1)
        // Source location is only shown for log levels up to `.debug`
        let expectedMessage =
            level <= Logger.Level.debug
            ? "logged (ConsoleLoggerTests/LoggingTests.swift:1)"
            : "logged"
        expect(printer: printer, logs: level, message: expectedMessage)
    }
}

private func expect(
    printer: TestingConsoleLoggerPrinter,
    logs level: Logger.Level,
    message: String,
    label: String = "codes.vapor.console",
    sourceLocation: SourceLocation = #_sourceLocation
) {
    #expect(
        printer.testOutputQueue.first ?? ""
            == "\(level == .trace ? "[ \(label) ] " : "")[ \(level.name) ] \(message)",
        sourceLocation: sourceLocation
    )
}

enum TraceNamespace {
    @TaskLocal static var simpleTraceID: String?
}

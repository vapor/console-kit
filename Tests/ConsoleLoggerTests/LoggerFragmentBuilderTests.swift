import ConsoleLogger
import Logging
import Testing

@Suite("LoggerFragmentBuilder Tests")
struct LoggerFragmentBuilderTests {
    @Test("Simple Fragment")
    func simpleFragment() throws {
        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            var consoleLogger = ConsoleLogger(label: label) {
                SpacedFragment {
                    "ConsoleLogger"
                    LabelFragment()
                    LevelFragment()
                    MessageFragment()
                }
            }
            consoleLogger.printer = printer
            return consoleLogger
        }

        logger.info("Test message")

        #expect(printer.testOutputQueue.first == "ConsoleLogger [ codes.vapor.console ] [ INFO ] Test message")
    }

    @Test("Conditional Fragment", arguments: [true, false])
    func conditionalFragment(includeTimestamp: Bool) throws {
        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            var consoleLogger = ConsoleLogger(label: label) {
                SpacedFragment {
                    if includeTimestamp {
                        TimestampFragment()
                    }
                    LevelFragment()
                    MessageFragment()
                }
            }
            consoleLogger.printer = printer
            return consoleLogger
        }

        logger.info("Test message")

        if includeTimestamp {
            #expect(printer.testOutputQueue.first?.contains("[ INFO ] Test message") == true)
        } else {
            #expect(printer.testOutputQueue.first == "[ INFO ] Test message")
        }
    }

    @Test("Array Fragment")
    func arrayFragment() throws {
        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            var consoleLogger = ConsoleLogger(label: label) {
                SpacedFragment {
                    for i in 1...2 {
                        "[PREFIX\(i)]"
                        LevelFragment()
                    }
                    MessageFragment()
                }
            }
            consoleLogger.printer = printer
            return consoleLogger
        }

        logger.info("Test message")

        #expect(printer.testOutputQueue.first == "[PREFIX1] [ INFO ] [PREFIX2] [ INFO ] Test message")
    }

    @Test("Empty Block")
    func emptyBlock() throws {
        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            var consoleLogger = ConsoleLogger(label: label) {
                // Empty block
            }
            consoleLogger.printer = printer
            return consoleLogger
        }

        logger.info("Test message")

        #expect(printer.testOutputQueue.first == "")
    }

    @Test("Complex Conditional Fragment", arguments: [Logger.Level.error, .warning, .info])
    func complexConditionalFragment(level: Logger.Level) throws {
        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            var consoleLogger = ConsoleLogger(label: label) {
                if level >= .error {
                    "X"
                } else if level >= .warning {
                    "!"
                } else {
                    "i"
                }

                LevelFragment().separated(" ")
                MessageFragment().separated(" ")
            }
            consoleLogger.printer = printer
            return consoleLogger
        }

        logger.info("Test message")

        if level >= .error {
            #expect(printer.testOutputQueue.first == "X [ INFO ] Test message")
        } else if level >= .warning {
            #expect(printer.testOutputQueue.first == "! [ INFO ] Test message")
        } else {
            #expect(printer.testOutputQueue.first == "i [ INFO ] Test message")
        }
    }

    @Test("Default built with LoggerFragmentBuilder")
    func defaultFragment() throws {
        let loggerBuilderPrinter = TestingConsoleLoggerPrinter()
        let loggerBuilder = Logger(label: "codes.vapor.console") { label in
            var consoleLogger = ConsoleLogger(label: label) {
                // This is the default logger fragment, but built using LoggerFragmentBuilder
                SpacedFragment {
                    LabelFragment().maxLevel(.trace)
                    LevelFragment()
                    MessageFragment()
                    MetadataFragment()
                    SourceLocationFragment().maxLevel(.debug)
                }
            }
            consoleLogger.printer = loggerBuilderPrinter
            return consoleLogger
        }

        let defaultLoggerPrinter = TestingConsoleLoggerPrinter()
        let defaultLogger = Logger(label: "codes.vapor.console") { label in
            var consoleLogger = ConsoleLogger(label: label)
            consoleLogger.printer = defaultLoggerPrinter
            return consoleLogger
        }

        loggerBuilder.info("Test message", metadata: ["key": "value"], line: 1)
        defaultLogger.info("Test message", metadata: ["key": "value"], line: 1)

        #expect(loggerBuilderPrinter.testOutputQueue[0] == defaultLoggerPrinter.testOutputQueue[0])
    }
}

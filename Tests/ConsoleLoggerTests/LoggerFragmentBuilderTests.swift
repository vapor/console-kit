import ConsoleLogger
import Logging
import Testing

@Suite("LoggerFragmentBuilder Tests")
struct LoggerFragmentBuilderTests {
    @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, macCatalyst 26.0, visionOS 26.0, *)
    @Test("LoggerFragmentBuilder")
    func loggerFragmentBuilder() throws {
        let printer = TestingConsoleLoggerPrinter()

        @LoggerFragmentBuilder<1>
        var fragment: some LoggerFragment {
            "Test"
            LabelFragment()
            LevelFragment()
            MessageFragment()
            MetadataFragment()
            SourceLocationFragment()
        }

        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(fragment: fragment, printer: printer, label: label)
        }

        logger.info("Test message", metadata: ["key": "value"], line: 1)

        #expect(printer.testOutputQueue.first == "Test [ codes.vapor.console ] [ INFO ] Test message [key: value] (\(#fileID):1)")
    }

    @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, macCatalyst 26.0, visionOS 26.0, *)
    @Test("LoggerFragmentBuilder with zero spaces")
    func loggerFragmentBuilderZeroSpaces() throws {
        let printer = TestingConsoleLoggerPrinter()

        @LoggerFragmentBuilder<0>
        var fragment: some LoggerFragment {
            "Test"
            LabelFragment()
            LevelFragment()
            MessageFragment()
            MetadataFragment()
            SourceLocationFragment()
        }

        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(fragment: fragment, printer: printer, label: label)
        }

        logger.info("Test message", metadata: ["key": "value"], line: 1)

        #expect(printer.testOutputQueue.first == "Test[ codes.vapor.console ][ INFO ]Test message[key: value](\(#fileID):1)")
    }

    @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, macCatalyst 26.0, visionOS 26.0, *)
    @Test("Simple Fragment")
    func simpleFragment() throws {
        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(printer: printer, label: label) {
                SpacedFragment {
                    "ConsoleLogger"
                    LabelFragment()
                    LevelFragment()
                    MessageFragment()
                }
            }
        }

        logger.info("Test message")

        #expect(printer.testOutputQueue.first == "ConsoleLogger [ codes.vapor.console ] [ INFO ] Test message")
    }

    @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, macCatalyst 26.0, visionOS 26.0, *)
    @Test("Conditional Fragment", arguments: [true, false])
    func conditionalFragment(includeTimestamp: Bool) throws {
        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(printer: printer, label: label) {
                SpacedFragment {
                    if includeTimestamp {
                        TimestampFragment()
                    }
                    LevelFragment()
                    MessageFragment()
                }
            }
        }

        logger.info("Test message")

        if includeTimestamp {
            #expect(printer.testOutputQueue.first?.contains("[ INFO ] Test message") == true)
        } else {
            #expect(printer.testOutputQueue.first == "[ INFO ] Test message")
        }
    }

    @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, macCatalyst 26.0, visionOS 26.0, *)
    @Test("Array Fragment")
    func arrayFragment() throws {
        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(printer: printer, label: label) {
                SpacedFragment {
                    for i in 1...2 {
                        "[PREFIX\(i)]"
                        LevelFragment()
                    }
                    MessageFragment()
                }
            }
        }

        logger.info("Test message")

        #expect(printer.testOutputQueue.first == "[PREFIX1] [ INFO ] [PREFIX2] [ INFO ] Test message")
    }

    @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, macCatalyst 26.0, visionOS 26.0, *)
    @Test("Empty Block")
    func emptyBlock() throws {
        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(printer: printer, label: label) {
                // Empty block
            }
        }

        logger.info("Test message")

        #expect(printer.testOutputQueue.first == "")
    }

    @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, macCatalyst 26.0, visionOS 26.0, *)
    @Test("Complex Conditional Fragment", arguments: [Logger.Level.error, .warning, .info])
    func complexConditionalFragment(level: Logger.Level) throws {
        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(printer: printer, label: label) {
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

    @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, macCatalyst 26.0, visionOS 26.0, *)
    @Test("Default built with LoggerFragmentBuilder")
    func defaultFragment() throws {
        let loggerBuilderPrinter = TestingConsoleLoggerPrinter()
        let loggerBuilder = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(printer: loggerBuilderPrinter, label: label) {
                // This is the default logger fragment, but built using LoggerFragmentBuilder
                SpacedFragment {
                    LabelFragment().maxLevel(.trace)
                    LevelFragment()
                    MessageFragment()
                    MetadataFragment()
                    SourceLocationFragment().maxLevel(.debug)
                }
            }
        }

        let defaultLoggerPrinter = TestingConsoleLoggerPrinter()
        let defaultLogger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(printer: defaultLoggerPrinter, label: label)
        }

        loggerBuilder.info("Test message", metadata: ["key": "value"], line: 1)
        defaultLogger.info("Test message", metadata: ["key": "value"], line: 1)

        #expect(loggerBuilderPrinter.testOutputQueue[0] == defaultLoggerPrinter.testOutputQueue[0])
    }

    @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, macCatalyst 26.0, visionOS 26.0, *)
    @Test("Empty separator does not consume needsSeparator")
    func emptySeparator() throws {
        let printer = TestingConsoleLoggerPrinter()
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(printer: printer, label: label) {
                "Hello"
                LevelFragment().separated("")
                MessageFragment().separated(" ")
            }
        }

        logger.info("Test message")

        // `.separated("")` should not insert any text but also should not consume the `needsSeparator` flag,
        // so the next `.separated(" ")` still inserts a space.
        #expect(printer.testOutputQueue.first == "Hello[ INFO ] Test message")
    }
}

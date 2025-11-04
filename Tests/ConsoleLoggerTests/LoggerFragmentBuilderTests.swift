import ConsoleLogger
import Logging
import Testing

@Suite("LoggerFragmentBuilder Tests")
struct LoggerFragmentBuilderTests {
    @Test("Simple Fragment")
    func simpleFragment() throws {
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label) {
                SpacedFragment {
                    "ConsoleLogger"
                    LabelFragment()
                    LevelFragment()
                    MessageFragment()
                }
            }
        }

        logger.info("Test message")

        //#expect(console.testOutputQueue.first == "ConsoleLogger [ codes.vapor.console ] [ INFO ] Test message\n")
    }

    @Test("Conditional Fragment", arguments: [true, false])
    func conditionalFragment(includeTimestamp: Bool) throws {
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label) {
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
            //#expect(console.testOutputQueue.first?.contains("[ INFO ] Test message") == true)
        } else {
            //#expect(console.testOutputQueue.first == "[ INFO ] Test message\n")
        }
    }

    @Test("Array Fragment")
    func arrayFragment() throws {
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label) {
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

        //#expect(console.testOutputQueue.first == "[PREFIX1] [ INFO ] [PREFIX2] [ INFO ] Test message\n")
    }

    @Test("Empty Block")
    func emptyBlock() throws {
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label) {
                // Empty block
            }
        }

        logger.info("Test message")

        //#expect(console.testOutputQueue.first == "\n")
    }

    @Test("Complex Conditional Fragment", arguments: [Logger.Level.error, .warning, .info])
    func complexConditionalFragment(level: Logger.Level) throws {
        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label) {
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
            //#expect(console.testOutputQueue.first == "X [ INFO ] Test message\n")
        } else if level >= .warning {
            //#expect(console.testOutputQueue.first == "! [ INFO ] Test message\n")
        } else {
            //#expect(console.testOutputQueue.first == "i [ INFO ] Test message\n")
        }
    }

    @Test("Default built with LoggerFragmentBuilder")
    func defaultFragment() throws {
        let loggerBuilder = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label) {
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

        let defaultLogger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label)
        }

        loggerBuilder.info("Test message", metadata: ["key": "value"])
        defaultLogger.info("Test message", metadata: ["key": "value"])

        // Drop the last 5 characters which are the source location line number that can differ
        //#expect(console.testOutputQueue[0].dropLast(5) == console.testOutputQueue[1].dropLast(5))
    }
}

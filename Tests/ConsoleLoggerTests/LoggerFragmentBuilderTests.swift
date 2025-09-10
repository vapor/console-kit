import ConsoleKit
import ConsoleLogger
import Logging
import Testing

@Suite("LoggerFragmentBuilder Tests")
struct LoggerFragmentBuilderTests {
    @Test("Simple Fragment")
    func simpleFragment() throws {
        let console = TestConsole()

        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label, console: console) {
                SpacedFragment {
                    "ConsoleLogger"
                    LabelFragment()
                    LevelFragment()
                    MessageFragment()
                }
            }
        }

        logger.info("Test message")

        #expect(console.testOutputQueue.first == "ConsoleLogger [ codes.vapor.console ] [ INFO ] Test message\n")
    }

    @Test("Conditional Fragment", arguments: [true, false])
    func conditionalFragment(includeTimestamp: Bool) throws {
        let console = TestConsole()

        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label, console: console) {
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
            #expect(console.testOutputQueue.first?.contains("[ INFO ] Test message") == true)
        } else {
            #expect(console.testOutputQueue.first == "[ INFO ] Test message\n")
        }
    }

    @Test("Array Fragment")
    func arrayFragment() throws {
        let console = TestConsole()

        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label, console: console) {
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

        #expect(console.testOutputQueue.first == "[PREFIX1] [ INFO ] [PREFIX2] [ INFO ] Test message\n")
    }

    @Test("Empty Block")
    func emptyBlock() throws {
        let console = TestConsole()

        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label, console: console) {
                // Empty block
            }
        }

        logger.info("Test message")

        #expect(console.testOutputQueue.first == "\n")
    }

    @Test("Complex Conditional Fragment", arguments: [Logger.Level.error, .warning, .info])
    func complexConditionalFragment(level: Logger.Level) throws {
        let console = TestConsole()

        let logger = Logger(label: "codes.vapor.console") { label in
            ConsoleLogger(label: label, console: console) {
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
            #expect(console.testOutputQueue.first == "X [ INFO ] Test message\n")
        } else if level >= .warning {
            #expect(console.testOutputQueue.first == "! [ INFO ] Test message\n")
        } else {
            #expect(console.testOutputQueue.first == "i [ INFO ] Test message\n")
        }
    }
}

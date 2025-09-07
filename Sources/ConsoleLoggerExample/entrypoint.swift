import ConsoleKit
import ConsoleLogger
import Logging

@main
struct ConsoleLoggerExample {
    static func main() {
        LoggingSystem.bootstrap(
            fragment: .timestampDefault(),
            console: Terminal()
        )

        // Prints "2023-08-21T00:00:00Z [ INFO ] Logged!"
        Logger(label: "EXAMPLE").info("Logged!")
    }
}

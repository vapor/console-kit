import ConsoleLogger
import Logging

@main
struct ConsoleLoggerExample {
    static func main() {
        LoggingSystem.bootstrap(fragment: .timestampDefault())

        // Prints "2023-08-21T00:00:00Z [ INFO ] Logged!"
        Logger(label: "EXAMPLE").info("Logged!")
    }
}

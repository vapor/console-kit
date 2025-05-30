import ConsoleKit
import Foundation
import Logging

@main
struct ConsoleLoggerExample {
    static func main() {
        LoggingSystem.bootstrap(
            fragment: timestampDefaultLoggerFragment(),
            console: Terminal()
        )

        // Prints "2023-08-21T00:00:00Z [ INFO ] Logged!"
        Logger(label: "EXAMPLE").info("Logged!")
    }
}

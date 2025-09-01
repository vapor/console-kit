import ConsoleKit
import ConsoleLogger
import Logging

@main
struct ConsoleLoggerExample {
    static func main() {
        let console = Terminal()

        var customizedLoggerFragment: some LoggerFragment {
            LabelFragment().maxLevel(.trace)
                .and(LevelFragment().separated(" ").and(MessageFragment().separated(" ")))
                .and(MetadataFragment().separated(" "))
                .and(SourceLocationFragment().separated(" ").maxLevel(.debug))
        }

        LoggingSystem.bootstrap(
            fragment: customizedLoggerFragment,
            console: console
        )

        // Prints "[ INFO ] Logged!"
        Logger(label: "EXAMPLE").info("Logged!")
    }
}

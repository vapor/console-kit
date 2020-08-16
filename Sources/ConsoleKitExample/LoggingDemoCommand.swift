import ConsoleKit
import Logging

final class LoggingDemoCommand: Command {
    struct Signature: CommandSignature {
        enum ColorSetting: String, LosslessStringConvertible {
            case always, never, auto
            
            init?(_ description: String) { self.init(rawValue: description) }
            var description: String { self.rawValue }
        }
        
        @Option(name: "color", help: "'always' forces color output, 'never' forces plain text, 'auto' (the default) detects color support")
        var color: ColorSetting?

        init() {}
    }

    var help: String {
        "A demonstration of what ConsoleLogger can do"
    }

    func run(using context: CommandContext, signature: Signature) throws {
        // Implement the `--color=always|never|auto` option
        switch signature.color {
            case .none, .auto: context.console.stylizedOutputOverride = nil
            case .always: context.console.stylizedOutputOverride = true
            case .never: context.console.stylizedOutputOverride = false
        }
        
        // Bootstrap the logging system and make a logger.
        LoggingSystem.bootstrap(console: context.console, level: .trace)
        let logger1 = Logger(label: "codes.vapor.loggingdemo")
        
        // Demonstrate the default output and style configurations at the default level.
        context.console.info(context.console.center("Sample logger output with the default output, style, and level configuration"))
        context.console.info()
        for level in Logger.Level.allCases.sorted() {
            logger1.log(level: level, "This is a log message at the .\(level.rawValue) level")
        }
        context.console.info()
        
        // Set a different output and style configuration.
        let logger2 = Logger(label: "codes.vapor.loggingdemo", factory: { label in
            ConsoleLogger(
                label: label, console: context.console, level: .trace,
                metadata: ["test": .string("value")],
                settings: Logger.OutputConfiguration.init(timestampDisplayLogLevel: .critical, labelDisplayLogLevel: .critical, metadataDisplayLogLevel: .critical, sourceModuleDisplayLogLevel: .critical, sourceFileLineDisplayLogLevel: .critical, sourceFunctionDisplayLogLevel: .critical, defaultExcludedLabels: [], defaultExcludedRegularExpressions: [], timestampLoggingFormat: .highPrecisionISO8601),
                style: Logger.StyleConfiguration.init(
                    baseStyle: .init(color: .brightMagenta, background: .blue, isBold: true),
                    levelStyles: [
                        .critical: .init(color: .brightRed, background: .black, isBold: true),
                        .error: .init(color: .red, background: .black, isBold: true),
                        .warning: .init(color: .brightYellow, background: .brightBlack, isBold: true),
                        .info: .info,
                        .notice: .init(color: .brightCyan, background: .white, isBold: true),
                        .debug: .init(color: .brightGreen, background: .cyan, isBold: false),
                        .trace: .init(color: .brightWhite, background: .black, isBold: false),
                    ],
                    timestampStyle: .init(color: .brightGreen, background: .black, isBold: false),
                    labelStyle: .init(color: .blue, background: .white, isBold: false),
                    levelIndicatorStyle: .init(color: .white, background: .black, isBold: false),
                    metadataStyle: .init(color: .black, background: .white, isBold: false),
                    fileStyle: .init(color: .black, background: .white, isBold: false),
                    lineStyle: .init(color: .black, background: .white, isBold: false),
                    messageStyle: .init(color: .brightWhite, background: .black, isBold: true)
                )
            )
        })
        
        context.console.info(context.console.center("Sample logger output using an absolutely ridiculous style configuration"))
        context.console.info()
        for level in Logger.Level.allCases.sorted() {
            logger2.log(level: level, "This is a log message at the .\(level.rawValue) level")
        }
    }
}

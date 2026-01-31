public import Logging

#if ConfigReader
public import Configuration
#endif

extension ConsoleLogger {
    /// Bootstraps a ``ConsoleLogger`` to the `LoggingSystem`, so that logger will be used in `Logger.init(label:)`.
    ///
    /// ```swift
    /// ConsoleLogger.bootstrap()
    /// ```
    ///
    /// - Parameters:
    ///   - fragment: The logger fragment which will be used to build the logged messages.
    ///   - printer: The ``ConsoleLoggerPrinter`` used to output log messages.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.info`.
    ///   - metadata: Extra metadata to log with all messages. This defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to bootstrap the logging system with.
    public static func bootstrap(
        fragment: T = .default,
        printer: any ConsoleLoggerPrinter = DefaultConsoleLoggerPrinter(),
        level: Logger.Level = .info,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil
    ) {
        LoggingSystem.bootstrap(
            { ConsoleLogger(fragment: fragment, printer: printer, label: $0, level: level, metadata: metadata, metadataProvider: $1) },
            metadataProvider: metadataProvider
        )
    }

    /// Bootstraps a ``ConsoleLogger`` to the `LoggingSystem`, so that logger will be used in `Logger.init(label:)`.
    ///
    /// ```swift
    /// ConsoleLogger.bootstrap() {
    ///     TimestampFragment()
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - printer: The ``ConsoleLoggerPrinter`` used to output log messages.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.info`.
    ///   - metadata: Extra metadata to log with all messages. This defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to bootstrap the logging system with.
    ///   - fragment: The logger fragment which will be used to build the logged messages.
    public static func bootstrap(
        printer: any ConsoleLoggerPrinter = DefaultConsoleLoggerPrinter(),
        level: Logger.Level = .info,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil,
        @LoggerFragmentBuilder fragment: () -> T
    ) {
        self.bootstrap(fragment: fragment(), printer: printer, level: level, metadata: metadata, metadataProvider: metadataProvider)
    }

    #if ConfigReader
    /// Bootstraps a ``ConsoleLogger`` to the `LoggingSystem`, so that logger will be used in `Logger.init(label:)`.
    ///
    /// ```swift
    /// ConsoleLogger.bootstrapWithConfigReader(config: ConfigReader(...))
    /// ```
    ///
    /// ## Configuration keys
    /// - `log.level` (string, optional, default: `"info"`): The minimum level of message that the logger will output.
    ///
    /// - Parameters:
    ///   - fragment: The logger fragment which will be used to build the logged messages.
    ///   - printer: The ``ConsoleLoggerPrinter`` used to output log messages.
    ///   - config: The config reader to read the log level from. A default `ConfigReader` is provided which reads from command line arguments and environment variables.
    ///   - metadata: Extra metadata to log with all messages. This defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to bootstrap the logging system with.
    public static func bootstrapWithConfigReader(
        fragment: T = .default,
        printer: any ConsoleLoggerPrinter = DefaultConsoleLoggerPrinter(),
        config: ConfigReader = ConfigReader(providers: [CommandLineArgumentsProvider(), EnvironmentVariablesProvider()]),
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil
    ) {
        self.bootstrap(
            fragment: fragment,
            printer: printer,
            level: config.string(forKey: "log.level", as: Logger.Level.self, default: .info),
            metadata: metadata,
            metadataProvider: metadataProvider
        )
    }

    /// Bootstraps a ``ConsoleLogger`` to the `LoggingSystem`, so that logger will be used in `Logger.init(label:)`.
    ///
    /// ```swift
    /// ConsoleLogger.bootstrapWithConfigReader(config: ConfigReader(...)) {
    ///     TimestampFragment()
    /// }
    /// ```
    /// ## Configuration keys
    /// - `log.level` (string, optional, default: `"info"`): The minimum level of message that the logger will output.
    ///
    /// - Parameters:
    ///   - printer: The ``ConsoleLoggerPrinter`` used to output log messages.
    ///   - config: The config reader to read the log level from. A default `ConfigReader` is provided which reads from command line arguments and environment variables.
    ///   - metadata: Extra metadata to log with all messages. This defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to bootstrap the logging system with.
    ///   - fragment: The logger fragment which will be used to build the logged messages.
    public static func bootstrapWithConfigReader(
        printer: any ConsoleLoggerPrinter = DefaultConsoleLoggerPrinter(),
        config: ConfigReader = ConfigReader(providers: [CommandLineArgumentsProvider(), EnvironmentVariablesProvider()]),
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil,
        @LoggerFragmentBuilder fragment: () -> T
    ) {
        self.bootstrapWithConfigReader(
            fragment: fragment(),
            printer: printer,
            config: config,
            metadata: metadata,
            metadataProvider: metadataProvider
        )
    }
    #endif
}

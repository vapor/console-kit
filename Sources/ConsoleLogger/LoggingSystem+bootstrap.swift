public import Configuration
public import Logging

extension LoggingSystem {
    /// Bootstraps a ``ConsoleLogger`` to the `LoggingSystem`, so that logger will be used in `Logger.init(label:)`.
    ///
    /// ```swift
    /// LoggingSystem.boostrap()
    /// ```
    ///
    /// - Parameters:
    ///   - fragment: The logger fragment which will be used to build the logged messages.
    ///   - printer: The ``ConsoleLoggerPrinter`` used to output log messages.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.info`.
    ///   - metadata: Extra metadata to log with all messages. This defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to bootstrap the logging system with.
    public static func bootstrap(
        fragment: some LoggerFragment = .default,
        printer: any ConsoleLoggerPrinter = DefaultConsoleLoggerPrinter(),
        level: Logger.Level = .info,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil
    ) {
        self.bootstrap(
            { ConsoleLogger(fragment: fragment, printer: printer, label: $0, level: level, metadata: metadata, metadataProvider: $1) },
            metadataProvider: metadataProvider
        )
    }

    /// Bootstraps a ``ConsoleLogger`` to the `LoggingSystem`, so that logger will be used in `Logger.init(label:)`.
    ///
    /// ```swift
    /// LoggingSystem.boostrap() {
    ///     TimestampFragment()
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - print: The ``ConsoleLoggerPrinter`` used to output log messages.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.info`.
    ///   - metadata: Extra metadata to log with all messages. This defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to bootstrap the logging system with.
    ///   - fragment: The logger fragment which will be used to build the logged messages.
    public static func bootstrap(
        print: any ConsoleLoggerPrinter = DefaultConsoleLoggerPrinter(),
        level: Logger.Level = .info,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil,
        @LoggerFragmentBuilder fragment: () -> some LoggerFragment
    ) {
        self.bootstrap(fragment: fragment(), level: level, metadata: metadata, metadataProvider: metadataProvider)
    }

    /// Bootstraps a ``ConsoleLogger`` to the `LoggingSystem`, so that logger will be used in `Logger.init(label:)`.
    ///
    /// ```swift
    /// LoggingSystem.boostrap(config: ConfigReader(...))
    /// ```
    ///
    /// ## Configuration keys
    /// - `log.level` (string, optional, default: `"info"`): The minimum level of message that the logger will output.
    ///
    /// - Parameters:
    ///   - fragment: The logger fragment which will be used to build the logged messages.
    ///   - printer: The ``ConsoleLoggerPrinter`` used to output log messages.
    ///   - config: The config reader to read the log level from. This defaults to `.info`.
    ///   - metadata: Extra metadata to log with all messages. This defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to bootstrap the logging system with.
    public static func bootstrap(
        fragment: some LoggerFragment = .default,
        printer: any ConsoleLoggerPrinter = DefaultConsoleLoggerPrinter(),
        config: ConfigReader,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil
    ) {
        self.bootstrap(
            {
                ConsoleLogger(
                    fragment: fragment,
                    printer: printer,
                    label: $0,
                    level: config.string(forKey: "log.level", as: Logger.Level.self, default: .info),
                    metadata: metadata,
                    metadataProvider: $1
                )
            },
            metadataProvider: metadataProvider
        )
    }

    /// Bootstraps a ``ConsoleLogger`` to the `LoggingSystem`, so that logger will be used in `Logger.init(label:)`.
    ///
    /// ```swift
    /// LoggingSystem.boostrap(config: ConfigReader(...)) {
    ///     TimestampFragment()
    /// }
    /// ```
    /// ## Configuration keys
    /// - `log.level` (string, optional, default: `"info"`): The minimum level of message that the logger will output.
    ///
    /// - Parameters:
    ///   - print: The ``ConsoleLoggerPrinter`` used to output log messages.
    ///   - config: The config reader to read the log level from. This defaults to `.info`.
    ///   - metadata: Extra metadata to log with all messages. This defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to bootstrap the logging system with.
    ///   - fragment: The logger fragment which will be used to build the logged messages.
    public static func bootstrap(
        print: any ConsoleLoggerPrinter = DefaultConsoleLoggerPrinter(),
        config: ConfigReader,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil,
        @LoggerFragmentBuilder fragment: () -> some LoggerFragment
    ) {
        self.bootstrap(fragment: fragment(), config: config, metadata: metadata, metadataProvider: metadataProvider)
    }
}

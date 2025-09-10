public import ConsoleKit
public import Logging

extension LoggingSystem {
    /// Bootstraps a ``ConsoleLogger`` to the `LoggingSystem`, so that logger will be used in `Logger.init(label:)`.
    ///
    /// ```swift
    /// LoggingSystem.boostrap(console: console)
    /// ```
    ///
    /// - Parameters:
    ///   - fragment: The logger fragment which will be used to build the logged messages.
    ///   - console: The console the logger will log the messages to.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.info`.
    ///   - metadata: Extra metadata to log with all messages. This defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to bootstrap the logging system with.
    public static func bootstrap(
        fragment: some LoggerFragment = .default,
        console: any Console,
        level: Logger.Level = .info,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil
    ) {
        self.bootstrap(
            { (label, metadataProvider) in
                return ConsoleLogger(
                    fragment: fragment, label: label, console: console, level: level, metadata: metadata, metadataProvider: metadataProvider
                )
            },
            metadataProvider: metadataProvider
        )
    }

    /// Bootstraps a ``ConsoleLogger`` to the `LoggingSystem`, so that logger will be used in `Logger.init(label:)`.
    ///
    /// ```swift
    /// LoggingSystem.boostrap(console: console) {
    ///     TimestampFragment()
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - fragment: The logger fragment which will be used to build the logged messages.
    ///   - console: The console the logger will log the messages to.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.info`.
    ///   - metadata: Extra metadata to log with all messages. This defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to bootstrap the logging system with.
    public static func bootstrap(
        console: any Console,
        level: Logger.Level = .info,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil,
        @LoggerFragmentBuilder fragment: () -> some LoggerFragment
    ) {
        self.bootstrap(fragment: fragment(), console: console, level: level, metadata: metadata, metadataProvider: metadataProvider)
    }
}

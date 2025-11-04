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
    ///   - level: The minimum level of message that the logger will output. This defaults to `.info`.
    ///   - metadata: Extra metadata to log with all messages. This defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to bootstrap the logging system with.
    public static func bootstrap(
        fragment: some LoggerFragment = .default,
        level: Logger.Level = .info,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil
    ) {
        self.bootstrap(
            { ConsoleLogger(fragment: fragment, label: $0, level: level, metadata: metadata, metadataProvider: $1) },
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
    ///   - level: The minimum level of message that the logger will output. This defaults to `.info`.
    ///   - metadata: Extra metadata to log with all messages. This defaults to an empty dictionary.
    ///   - metadataProvider: The metadata provider to bootstrap the logging system with.
    ///   - fragment: The logger fragment which will be used to build the logged messages.
    public static func bootstrap(
        level: Logger.Level = .info,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil,
        @LoggerFragmentBuilder fragment: () -> some LoggerFragment
    ) {
        self.bootstrap(fragment: fragment(), level: level, metadata: metadata, metadataProvider: metadataProvider)
    }
}

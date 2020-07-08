import Logging

extension Logger {
    /// A series of parameters describing the `ConsoleStyle`s used by `ConsoleLogger`-backed loggers for rendering
    /// various aspects of their output. The style configuration does _not_ control which components of a logger's
    /// output are visible, nor does it describe inclusion or exclusion criteria for particular outputs.
    ///
    /// If any given parameter is `nil`, the default fallback is used.
    public struct StyleConfiguration {
        /// The style used for all log text with no other defined style. The default is `.plain`
        let baseStyle: ConsoleStyle
        
        /// A dictionary mapping log levels to styles. If an entry exists for a given level, that style _replaces_ the
        /// base style for log messages with that level. The base style is used for all other levels.
        let levelStyles: [Logger.Level: ConsoleStyle]
        
        /// The style used for a log message's timestamp.
        let timestampStyle: ConsoleStyle?
        
        /// The style used for a log message's label, when visible.
        let labelStyle: ConsoleStyle?
        
        /// The style used to present a log message's level.
        let levelIndicatorStyle: ConsoleStyle?
        
        /// The style used for a log message's metadata, when visible.
        let metadataStyle: ConsoleStyle?
        
        /// The style used for a log message's source module, when visible.
        let moduleStyle: ConsoleStyle?
        
        /// The style used for a log message's source path, when visible.
        let fileStyle: ConsoleStyle?
        
        /// The style used for a log message's line number, when visible.
        let lineStyle: ConsoleStyle?
        
        /// The style used for a log message's source function, when visible.
        let functionStyle: ConsoleStyle?
        
        /// The style used for the actual content of a log message.
        let messageStyle: ConsoleStyle?
        
        /// Create a `StyleConfiguration`
        public init(
            baseStyle: ConsoleStyle = .plain,
            levelStyles: [Logger.Level: ConsoleStyle] = [:],
            timestampStyle: ConsoleStyle? = nil,
            labelStyle: ConsoleStyle? = nil,
            levelIndicatorStyle: ConsoleStyle? = nil,
            metadataStyle: ConsoleStyle? = nil,
            moduleStyle: ConsoleStyle? = nil,
            fileStyle: ConsoleStyle? = nil,
            lineStyle: ConsoleStyle? = nil,
            functionStyle: ConsoleStyle? = nil,
            messageStyle: ConsoleStyle? = nil
        ) {
            self.baseStyle = baseStyle
            self.levelStyles = levelStyles
            self.timestampStyle = timestampStyle
            self.labelStyle = labelStyle
            self.levelIndicatorStyle = levelIndicatorStyle
            self.metadataStyle = metadataStyle
            self.moduleStyle = moduleStyle
            self.fileStyle = fileStyle
            self.lineStyle = lineStyle
            self.functionStyle = functionStyle
            self.messageStyle = messageStyle
        }
    }
}

extension Logger.StyleConfiguration {
    /// The default style configuration adopted by `ConsoleLogger`.
    public static var `default`: Self { .init(
        baseStyle: .plain,
        levelStyles: [
            .critical: .init(color: .brightRed),
            .error: .error,
            .warning: .warning,
            .notice: .info,
            .info: .info,
        ],
        timestampStyle: nil,
        labelStyle: nil,
        levelIndicatorStyle: nil,
        metadataStyle: nil,
        moduleStyle: nil,
        fileStyle: nil,
        lineStyle: nil,
        functionStyle: nil,
        messageStyle: nil
    ) }
}

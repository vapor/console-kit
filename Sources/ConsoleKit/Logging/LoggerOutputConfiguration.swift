import Logging
import struct Foundation.Date

extension Logger {
    /// A series of parameters describing which elements of a log message are emitted by a `ConsoleLogger`-backed
    /// logger, and provides optional defaults for inclusion or exclusion criteria based on those elements.
    ///
    /// Many output parameters are described in terms of a "maximum log level" - such parameters have their described
    /// effect if and only if the log level of the `Logger` (not the individual message) is _at or below_ the configured
    /// level, as determined by the `Comparable` conformance of `Logger.Level`. For example, for a maximum level of
    /// "info", the parameter will apply when the logger is configured at `info`, `debug`, and `trace` levels, but not
    /// for any others. Setting any such parameter to `.critical` is equivalent to an "always" condition. Setting such a
    /// parameter to `nil` is equivalent to a "never" condition.
    ///
    /// - Note: Certain elements of a log message are always visible at all log levels unless the entire message has
    ///   been excluded. These are currently the log level and the message itself. It is **STRONGLY** recommended that
    ///   timestamp display be set to the `.error` level to guarantee minimally viable event tracking, especially in the
    ///   event that log messages do not appear in the correct order.
    public struct OutputConfiguration {
        /// The maximum log level at which a timestamp element is included in a log message.
        let timestampDisplayLogLevel: Logger.Level?
        
        /// The maximum log level at which a label element is included in a log message.
        let labelDisplayLogLevel: Logger.Level?
        
        /// The maximum log level at which metadata elements are included in a log message.
        let metadataDisplayLogLevel: Logger.Level?
        
        /// The maximum log level at which a source module element is included in a log message.
        ///
        /// - Warning: This setting is currently **ignored**; at present, the source module element is never emitted.
        let sourceModuleDisplayLogLevel: Logger.Level?
        
        /// The maximum log level at which source file and line elements are included in a log message.
        let sourceFileLineDisplayLogLevel: Logger.Level?
        
        /// The maximum log level at which a source function element is included in a log message.
        ///
        /// - Warning: This setting is currently **ignored**; at present, the source function element is never emitted.
        let sourceFunctionDisplayLogLevel: Logger.Level?
        
        /// A list of logger labels which are excluded from display by default. Wildcards are **not** recognized.
        let defaultExcludedLabels: [String]
        
        /// A list of regular expressions compatible with `NSRegularExpression` for which log message text matching at
        /// least one of the expressions is excluded from display by default .
        ///
        /// - Warning: Using exclusion regexps is **EXTREMELY** slow!!! Consider not using this. Ever.
        /// - Warning: Any invalid regexp provided in this array will cause a fatal error. Do not allow this list to be
        ///   populated from user input that has not first been fully validated.
        ///
        /// - Important: This support is obviously a bit of a questionable idea to have at all. It is here because there
        ///   exist certain cases of noisy and/or intrusive logging which can not be silenced by any other means, and
        ///   should be avoided unless no other options are available.
        let defaultExcludedRegularExpressions: [String]
        
        /// The date formatting function to use for displaying timestamps in log messages, when visible. Expressed as
        /// one of several predefined functions, or a closure for providing a custom format.
        ///
        /// - Warning: Formatting a timestamp for display can significantly degrade performance if the formatter in use
        ///   performs poorly when repeatedly and rapidly invoked. Most `DateFormatter`s have this problem when
        ///   configured with a timezone or locale other than the default.
        let timestampLoggingFormat: TimestampLoggingFormat
        
        /// Create an `OutputConfiguration`.
        public init(
            timestampDisplayLogLevel: Logger.Level? = nil,
            labelDisplayLogLevel: Logger.Level? = nil,
            metadataDisplayLogLevel: Logger.Level? = nil,
            sourceModuleDisplayLogLevel: Logger.Level? = nil,
            sourceFileLineDisplayLogLevel: Logger.Level? = nil,
            sourceFunctionDisplayLogLevel: Logger.Level? = nil,
            defaultExcludedLabels: [String] = [],
            defaultExcludedRegularExpressions: [String] = [],
            timestampLoggingFormat: TimestampLoggingFormat = .highPrecisionISO8601
        ) {
            self.timestampDisplayLogLevel = timestampDisplayLogLevel
            self.labelDisplayLogLevel = labelDisplayLogLevel
            self.metadataDisplayLogLevel = metadataDisplayLogLevel
            self.sourceModuleDisplayLogLevel = sourceModuleDisplayLogLevel
            self.sourceFileLineDisplayLogLevel = sourceFileLineDisplayLogLevel
            self.sourceFunctionDisplayLogLevel = sourceFunctionDisplayLogLevel
            self.defaultExcludedLabels = defaultExcludedLabels
            self.defaultExcludedRegularExpressions = defaultExcludedRegularExpressions
            self.timestampLoggingFormat = timestampLoggingFormat
        }
    }
}

extension Logger.OutputConfiguration {
    /// A date formatting function used to prepare timestamps for display in log messages. Distinct from both the
    /// `DateEncodingStrategy` of `JSONEncoder` and the `TimestampFormat` used by FluentKit in that both represent a
    /// different usage model for the date values with which they are concerned. This enum attempts to offer the most
    /// common and useful options for working with log messages, including consideration of efficiency concerns.
    public enum TimestampLoggingFormat {
        /// The canonical ISO 8601 date format, plus six fractional digits (potentially including trailing zeroes)
        /// representing up to 1 nanosecond of precision (but usually less). Only the UTC timezone is used. As permitted
        /// by the standard, the `T` character between the date and time components of the format is replaced with a
        /// single ASCII space for enhanced readability. This is the default timestamp format; it can be prepared for
        /// display with sufficient efficiency to support at least 100,000 log messages per second (very
        /// conservatively), is both human-readable and relatively easily machine-parsed, and conveys the full date and
        /// time of an event in a reasonably compact visual space.
        case highPrecisionISO8601
        
        /// A minimal timestamp format that attempts to consume an absolute minimum of visual space while still
        /// conveying the necessary information. Unlike the ISO 8601 format, the output may be of variable length. The
        /// timestamp will be represented in the UTC timezone and using the current locale, to the extent meaningful.
        case minimal
        
        /// A format which allows the user to specify an arbitrary closure to perform timestamp display formatting. The
        /// closure is passed the `Date` of the event to be logged and must return a `String` to be included in the
        /// resulting log message. The configured timestamp style, if any, will be applied to the result. The closure
        /// will not be invoked for log messages which will not be displayed, or in cases where the timestamp is not
        /// part of the message output. If any error occurs preventing formatting, the closure must return as reasonable
        /// a fallback as it can, such as the raw decimal value of the input date. Returning an empty string is
        /// accepted but is strongly discouraged.
        case custom((Date) -> String)
    }
}

extension Logger.OutputConfiguration {
    /// The default output configuration adopted by `ConsoleLogger`.
    ///
    /// - Note: This configuration is not currently the actually desired default; it emulates the behavior which
    ///   `ConsoleLogger` exhibited before this API was added. A future update to this package may replace this
    ///   configuration with a more suitable set of defaults.
    public static var `default`: Self { .init(
        timestampDisplayLogLevel: nil, // original logger never showed timestamp
        labelDisplayLogLevel: .trace,
        metadataDisplayLogLevel: .critical,
        sourceModuleDisplayLogLevel: nil,
        sourceFileLineDisplayLogLevel: .debug,
        sourceFunctionDisplayLogLevel: nil,
        defaultExcludedLabels: [],
        defaultExcludedRegularExpressions: [],
        timestampLoggingFormat: .highPrecisionISO8601
    ) }
}

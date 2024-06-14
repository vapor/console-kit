import Logging
import Foundation

/// Information about a specific log message, including information from the logger the message was logged to.
public struct LogRecord {
    public init(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata? = nil, source: String, file: String, function: String, line: UInt, label: String, loggerLevel: Logger.Level, loggerMetadata: Logger.Metadata, metadataProvider: Logger.MetadataProvider? = nil) {
        self.level = level
        self.message = message
        self.metadata = metadata
        self.source = source
        self.file = file
        self.function = function
        self.line = line
        self.label = label
        self.loggerLevel = loggerLevel
        self.loggerMetadata = loggerMetadata
        self.metadataProvider = metadataProvider
    }
    
    /// The log level of the message
    public var level: Logger.Level
    /// The logged message
    public var message: Logger.Message
    /// The metadata explicitly associated with the logged message
    public var metadata: Logger.Metadata?
    /// The source of the log message, usually the module name
    public var source: String
    /// The file the message was logged from
    public var file: String
    /// The function the message was logged from
    public var function: String
    /// The line number in the file the message was logged from
    public var line: UInt
    
    
    /// The label of the logger the message was logged to
    public var label: String
    /// The log level of the logger the message was logged to
    public var loggerLevel: Logger.Level
    /// The metadata associated with the logger the message was logged to
    public var loggerMetadata: Logger.Metadata
    /// The metadata provider associated with the logger the message was logged to
    public var metadataProvider: Logger.MetadataProvider?
    
    /// Combine all of the metadata into a single set.
    public mutating func allMetadata() -> [String: Logger.MetadataValue] {
        // We aren't mutating self here currently, but keeping the method marked that way will ensure we can cache the result without breaking the public API if we decide that's desirable.
        (self.metadata ?? [:])
            .merging(self.loggerMetadata, uniquingKeysWith: { (a, _) in a })
            .merging(self.metadataProvider?.get() ?? [:], uniquingKeysWith: { (a, _) in a })
    }
}

/// The output of a `LoggerFragment`, including some intermediary state used for things like deduplicating separators.
public struct FragmentOutput {
    public var text = ConsoleText()
    public var needsSeparator = false
    
    public init() { }
    
    public static func +=(lhs: inout FragmentOutput, rhs: ConsoleText) {
        lhs.text = ConsoleText(fragments: lhs.text.fragments + rhs.fragments)
    }
}

/// A fragment of a log message.
public protocol LoggerFragment: Sendable {
    /// Indicates whether the fragment will write anything to `output` when `write` is called. This is used to determine whether writing a separator should be skipped.
    func hasContent(record: inout LogRecord) -> Bool
    
    /// Add this fragment's output to the console text.
    ///
    /// Fragments are allowed to mutate the `LogRecord` seen by later fragments in the pipeline, but this should generally be done before any fragments write text to avoid inconsistencies in the final message.
    func write(_ record: inout LogRecord, to output: inout FragmentOutput)
}

extension LoggerFragment {
    public func hasContent(record: inout LogRecord) -> Bool {
        // Most fragments have content unconditionally.
        true
    }
}

public extension LoggerFragment {
    /// Make the current fragment conditional, only calling its `output` method if the record's `loggerLevel` is `maxLevel` or lower
    ///
    /// The sequence
    /// ```
    /// Literal("IsDebugOrTrace").maxLevel(.debug)
    /// ```
    /// will only include "IsDebugOrTrace" in the output when the log level is debug or lower.
    func maxLevel(_ level: Logger.Level) -> IfMaxLevelFragment<Self> {
        IfMaxLevelFragment(self, maxLevel: level)
    }
    
    /// Combine the current fragment with another, which will be written after the current fragment finishes.
    func and<T: LoggerFragment>(_ other: T) -> AndFragment<Self, T> {
        AndFragment(self, other)
    }
    
    /// Add a literal prefix to the current fragment.
    func prefixed(_ text: ConsoleText) -> AndFragment<LiteralFragment, Self> {
        AndFragment(LiteralFragment(text), self)
    }
    
    /// Add a literal suffix to the current fragment.
    func suffixed(_ text: ConsoleText) -> AndFragment<Self, LiteralFragment> {
        AndFragment(self, LiteralFragment(text))
    }
    
    /// Appends the given separator text to the output before `self`'s output, as long as a separator is needed.
    ///
    /// If the wrapped fragment reports that it has no content, no separator will be inserted.
    func separated(_ text: ConsoleText) -> SeparatorFragment<Self> {
        SeparatorFragment(text, fragment: self)
    }
}

/// Make the current fragment conditional, only calling its `output` method if the record's `loggerLevel` is `maxLevel` or lower
///
/// The sequence
/// ```
/// Literal("IsDebugOrTrace").maxLevel(.debug)
/// ```
/// will only include "IsDebugOrTrace" in the output when the log level is debug or lower.
///
/// This fragment is considered to not have content if the logging level is higher than than `maxLevel`.
public struct IfMaxLevelFragment<T: LoggerFragment>: LoggerFragment {
    public let maxLevel: Logger.Level
    public let fragment: T
    
    public init(_ fragment: T, maxLevel: Logger.Level) {
        self.fragment = fragment
        self.maxLevel = maxLevel
    }
    
    func shouldWrite(_ record: LogRecord) -> Bool {
        record.loggerLevel <= self.maxLevel
    }
    
    public func hasContent(record: inout LogRecord) -> Bool {
        if self.shouldWrite(record) {
            return self.fragment.hasContent(record: &record)
        } else {
            return false
        }
    }
    
    public func write(_ record: inout LogRecord, to output: inout FragmentOutput) {
        if self.shouldWrite(record) {
            self.fragment.write(&record, to: &output)
        }
    }
}

/// Combine the current fragment with another, which will be written after the current fragment finishes.
public struct AndFragment<T: LoggerFragment, U: LoggerFragment>: LoggerFragment {
    public let first: T
    public let second: U
    
    public init(_ first: T, _ second: U) {
        self.first = first
        self.second = second
    }
    
    public func hasContent(record: inout LogRecord) -> Bool {
        self.first.hasContent(record: &record) || self.second.hasContent(record: &record)
    }
    
    public func write(_ record: inout LogRecord, to output: inout FragmentOutput) {
        self.first.write(&record, to: &output)
        self.second.write(&record, to: &output)
    }
}

/// Writes the label of the logger, and requests a separator for the next fragment.
public struct LabelFragment: LoggerFragment {
    public init() { }
    
    public func write(_ record: inout LogRecord, to output: inout FragmentOutput) {
        output += "[ \(record.label) ]".consoleText()
        output.needsSeparator = true
    }
}

/// Writes the level of the logged message, and requests a separator for the next fragment.
public struct LevelFragment: LoggerFragment {
    public init() { }
    
    public func write(_ record: inout LogRecord, to output: inout FragmentOutput) {
        output += "[ \(record.level.name) ]".consoleText(record.level.style)
        output.needsSeparator = true
    }
}

/// Writes the given text to the output. This type does not request a separator for the next fragment
public struct LiteralFragment: LoggerFragment {
    public let literal: ConsoleText
    
    public init(_ literal: ConsoleText) {
        self.literal = literal
    }
    
    public func write(_ record: inout LogRecord, to output: inout FragmentOutput) {
        output += self.literal
    }
}

public struct SeparatorFragment<T: LoggerFragment>: LoggerFragment {
    public let literal: ConsoleText
    public var fragment: T
    
    public init(_ literal: ConsoleText, fragment: T) {
        self.literal = literal
        self.fragment = fragment
    }
    
    public func write(_ record: inout LogRecord, to output: inout FragmentOutput) {
        if output.needsSeparator {
            if self.fragment.hasContent(record: &record) {
                output.needsSeparator = false
                output += self.literal
            }
        }
        
        self.fragment.write(&record, to: &output)
    }
}

/// Writes the logged message to the output, and requests a separator for the next fragment.
public struct MessageFragment: LoggerFragment {
    public init() { }
    
    public func write(_ record: inout LogRecord, to output: inout FragmentOutput) {
        output += record.message.description.consoleText()
        output.needsSeparator = true
    }
}

/// Writes the combined metadata to the output, and requests a separator for the next fragment only if the metadata was not empty.
///
/// This fragment is considered to not have content if the metadata is empty.
public struct MetadataFragment: LoggerFragment {
    public init() { }
    
    public func hasContent(record: inout LogRecord) -> Bool {
        !record.allMetadata().isEmpty
    }
    
    public func write(_ record: inout LogRecord, to output: inout FragmentOutput) {
        let allMetadata = record.allMetadata()
        
        guard !allMetadata.isEmpty else { return }
        
        output += allMetadata.sortedDescriptionWithoutQuotes.consoleText()
        output.needsSeparator = true
    }
}

/// Writes the file location of the logged message, including the line. This fragment requests a separator for the next fragment.
public struct SourceLocationFragment: LoggerFragment {
    public init() { }
    
    public func write(_ record: inout LogRecord, to output: inout FragmentOutput) {
        let file = record.file + ":" + record.line.description
        output += "(" + file.consoleText() + ")"
        output.needsSeparator = true
    }
}

/// Writes the source of the logged message. By default the source is the name of the module the message was logged in.
public struct LoggerSourceFragment: LoggerFragment {
    public init() { }
    
    public func write(_ record: inout LogRecord, to output: inout FragmentOutput) {
        output += record.source.consoleText()
        output.needsSeparator = true
    }
}

/// A protocol to allow mocking the timestamp for tests
public protocol TimestampSource: Sendable {
    func now() -> tm
}

/// The default `TimestampSource`, which gets the time from the system.
public struct SystemTimestampSource: TimestampSource {
    public init() { }
    
    public func now() -> tm {
#if os(Windows)
        var timestamp = __time64_t()
        var localTime = tm()
        _ = _time64(&timestamp)
        _ = _localtime64_s(&localTime, &timestamp)
#else
        var timestamp = time(nil)
        var localTime = tm()
        localtime_r(&timestamp, &localTime)
#endif
        return localTime
    }
}

/// Writes a formatted timestamp based on the time obtained from the `TimestampSource`.
public struct TimestampFragment<S: TimestampSource>: LoggerFragment {
    let source: S
    
    public init(_ source: S = SystemTimestampSource()) { 
        self.source = source
    }
    
    public func write(_ record: inout LogRecord, to output: inout FragmentOutput) {
        output += self.timestamp().consoleText()
        output.needsSeparator = true
    }
    
    private func timestamp() -> String {
        withUnsafeTemporaryAllocation(of: CChar.self, capacity: 255) {
            var localTime = self.source.now()
            
            guard strftime($0.baseAddress!, $0.count, "%Y-%m-%dT%H:%M:%S%z", &localTime) > 0 else {
                return "<unknown>"
            }
            return String(cString: $0.baseAddress!)
        }
    }
}

private extension Logger.MetadataValue {
    var descriptionWithoutExcessQuotes: String {
        switch self {
        case .array(let array): return "[\(array.map(\.descriptionWithoutExcessQuotes).joined(separator: ", "))]"
        case .dictionary(let dict): return "[\(dict.map { "\($0): \($1.descriptionWithoutExcessQuotes)" }.joined(separator: ", "))]"
        case .string(let str): return str
        case .stringConvertible(let conv): return "\(conv)"
        }
    }
}

private extension Logger.Metadata {
    var sortedDescriptionWithoutQuotes: String {
        let contents = Array(self)
            .sorted(by: { $0.0 < $1.0 })
            .map { "\($0): \($1.descriptionWithoutExcessQuotes)" }
            .joined(separator: ", ")
        return "[\(contents)]"
    }
}

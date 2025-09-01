#if ConsoleLogger
import Logging

/// A ``LoggerFragment`` which implements the default logger message format.
public var defaultLoggerFragment: some LoggerFragment {
    LabelFragment().maxLevel(.trace)
        .and(LevelFragment().separated(" ").and(MessageFragment().separated(" ")))
        .and(MetadataFragment().separated(" "))
        .and(SourceLocationFragment().separated(" ").maxLevel(.debug))
}

/// A ``LoggerFragment`` which implements the default logger message format with a timestamp at the front.
public func timestampDefaultLoggerFragment(
    timestampSource: some TimestampSource = SystemTimestampSource()
) -> some LoggerFragment {
    TimestampFragment(timestampSource).and(defaultLoggerFragment.separated(" "))
}
#endif

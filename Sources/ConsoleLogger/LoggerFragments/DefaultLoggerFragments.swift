import Logging

/// The type of the default ``LoggerFragment``.
public typealias DefaultLoggerFragmentType = AndFragment<
    AndFragment<
        AndFragment<IfMaxLevelFragment<LabelFragment>, AndFragment<SeparatorFragment<LevelFragment>, SeparatorFragment<MessageFragment>>>,
        SeparatorFragment<MetadataFragment>
    >,
    IfMaxLevelFragment<SeparatorFragment<SourceLocationFragment>>
>

extension LoggerFragment where Self == DefaultLoggerFragmentType {
    /// A ``LoggerFragment`` which implements the default logger message format.
    public static var `default`: DefaultLoggerFragmentType {
        LabelFragment().maxLevel(.trace)
            .and(LevelFragment().separated(" ").and(MessageFragment().separated(" ")))
            .and(MetadataFragment().separated(" "))
            .and(SourceLocationFragment().separated(" ").maxLevel(.debug))
    }
}

/// The type of the default ``LoggerFragment`` with a timestamp.
public typealias TimestampDefaultLoggerFragmentType<TS: TimestampSource> = AndFragment<
    TimestampFragment<TS>, SeparatorFragment<DefaultLoggerFragmentType>
>

extension LoggerFragment where Self == TimestampDefaultLoggerFragmentType<SystemTimestampSource> {
    /// A ``LoggerFragment`` which implements the default logger message format with a timestamp at the front.
    public static func timestampDefault(
        timestampSource: some TimestampSource = SystemTimestampSource()
    ) -> some LoggerFragment {
        TimestampFragment(timestampSource).and(.default.separated(" "))
    }
}

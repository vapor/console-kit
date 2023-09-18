/// Possible states to draw / render and `ActivityIndicatorType`.
///
/// See `ActivityIndicatorType`.
public enum ActivityIndicatorState: Sendable {
    /// Default state. This is usually never used other than for initialization.
    case ready

    /// Active state. The indicator should appear active or loading during this state.
    ///
    /// See `ActivityIndicator.start(on:)`
    ///
    /// The `tick` parameter will increase by `1` each time the output is refreshed.
    /// This allows `ActivityIndicatorType` to create animations that happen over time
    /// without storing any internal state.
    case active(tick: UInt)

    /// Success state. The indicator should show that the operation succeeded.
    ///
    /// See `ActivityIndicator.fail()`
    ///
    /// Usually something green.
    case success

    /// Fail state. The indicator should show that the operation failed.
    ///
    /// See `ActivityIndicator.succeed()`
    ///
    /// Usually something red.
    case failure
}

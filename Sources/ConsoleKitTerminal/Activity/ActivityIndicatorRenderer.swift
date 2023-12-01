/// `ActivityIndicatorType`s are responsible for drawing / rendering the current `ActivityIndicatorState`
/// to the `Console`.
///
/// `ActivityIndicator`s are created from an instance of `ActivityIndicatorType` and control the implementation
/// behind calling the `ActivityIndicatorType` for `ActivityIndicatorState` changes.
///
/// See the `ActivityBar` protocol which is based off of this protocol.
public protocol ActivityIndicatorType: Sendable {
    /// Draws / renders this `ActivityIndicatorType` to the `Console` for the supplied `ActivityIndicatorState`.
    ///
    /// This method will be called by the `ActivityIndicator`. The `Console` will have any previous
    /// output cleared between calls to this method using the ephemeral push/pop methods.
    ///
    /// - parameters:
    ///     - console: `Console` to output this indicator to.
    ///     - state: State to draw the indicator in, e.g., active, failed.
    func outputActivityIndicator(to console: any Console, state: ActivityIndicatorState)
}

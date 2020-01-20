/// An `ActivityIndicatorType` that renders an activity bar on a single line.
///
///     Title [=======              ]
///
/// `ActivityBar`s implement the `renderActiveBar(tick:)` method to customize the bar style.
///
/// See `LoadingBar` and `ProgressBar` implementations.
///
/// See `ActivityIndicatorType` for more information.
public protocol ActivityBar: ActivityIndicatorType {
    /// The title to display when rendering this `ActivityBar`.
    var title: String { get }

    /// Called each time the `ActivityBar` should refresh its display.
    ///
    /// - parameters:
    ///     - tick: Increments each time this method is called. Use this number to
    ///             change the activity bar's appearance over time.
    /// - returns: Rendered activity bar.
    func renderActiveBar(tick: UInt, width: Int) -> ConsoleText
}

extension ActivityBar {
    /// See `ActivityIndicatorType`.
    public func outputActivityIndicator(to console: Console, state: ActivityIndicatorState) {
        let bar: ConsoleText
        switch state {
        case .ready: bar = "[]"
        case .active(let tick): bar = renderActiveBar(tick: tick, width: Self.width)
        case .success: bar = "[Done]".consoleText(.success)
        case .failure: bar = "[Failed]".consoleText(.error)
        }
        console.output(title.consoleText(.plain) + " " + bar)
    }
}

/// Defines the width of all `ActivityBar`s in characters.
private var _width: Int = 25

extension ActivityBar {
    /// Defines the width of all `ActivityBar`s in characters.
    public static var width: Int {
        get { return _width }
        set { _width = newValue}
    }
}

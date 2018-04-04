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
    func renderActiveBar(tick: UInt) -> String
}

extension ActivityBar {
    /// See `ActivityIndicatorType`.
    public func outputActivityIndicator(to console: Console, state: ActivityIndicatorState) {
        let bar: String
        let barStyle: ConsoleStyle
        switch state {
        case .ready:
            bar = "[]"
            barStyle = .plain
        case .active(let tick):
            bar = renderActiveBar(tick: tick)
            barStyle = .info
        case .success:
            bar = "[Done]"
            barStyle = .success
        case .failure:
            bar = "[Failed]"
            barStyle = .error
        }

        console.output("\(title) ", style: .plain, newLine: false)
        console.output(bar, style: barStyle)
    }
}

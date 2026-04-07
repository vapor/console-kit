/// An ``ActivityIndicatorType`` that renders an activity bar on a single line.
///
/// ```
/// Title [=======              ]
/// ```
///
/// ``ActivityBar``s implement the ``ActivityBar/renderActiveBar(tick:width:)`` method to customize the bar style.
///
/// See ``LoadingBar`` and ``ProgressBar`` implementations.
///
/// See ``ActivityIndicatorType`` for more information.
public protocol ActivityBar: ActivityIndicatorType {
    /// The title to display when rendering this ``ActivityBar``.
    var title: String { get }

    /// Called each time the ``ActivityBar`` should refresh its display.
    ///
    /// - parameters:
    ///     - tick: Increments each time this method is called. Use this number to change the activity bar's appearance over time.
    ///     - width: The width of the activity bar in characters.
    /// - returns: Rendered activity bar.
    func renderActiveBar(tick: UInt, width: Int) -> ConsoleText
}

extension ActivityBar {
    /// See ``ActivityIndicatorType``.
    public func outputActivityIndicator(to console: any Console, state: ActivityIndicatorState) {
        let bar: ConsoleText =
            switch state {
            case .ready: "[...]"
            case .active(let tick): renderActiveBar(tick: tick, width: console.activityBarWidth)
            case .success: "[Done]".consoleText(.success)
            case .failure: "[Failed]".consoleText(.error)
            }
        console.output(title.consoleText(.plain) + " " + bar)
    }
}

/// Key type for storing the activity bar width in the ``Console/userInfo`` of the related ``Console`` without colliding with end user keys.
struct ActivityBarWidthKey: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine("ConsoleKit.ActivityBarWidthKey")
    }
}

extension Console {
    public var activityBarWidth: Int {
        get {
            self.userInfo[ActivityBarWidthKey()] as? Int ?? 25
        }

        set {
            self.userInfo[ActivityBarWidthKey()] = newValue
        }
    }
}

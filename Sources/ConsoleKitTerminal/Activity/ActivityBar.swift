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
    public func outputActivityIndicator(to console: any Console, state: ActivityIndicatorState) {
        let bar: ConsoleText
        switch state {
        case .ready: bar = "[...]"
        case .active(let tick): bar = renderActiveBar(tick: tick, width: console.activityBarWidth)
        case .success: bar = "[Done]".consoleText(.success)
        case .failure: bar = "[Failed]".consoleText(.error)
        }
        console.output(title.consoleText(.plain) + " " + bar)
    }
}

extension ActivityBar {
    @available(*, deprecated, message: "This value has no effect. Use `console.activityBarWidth` instead.")
    public static var width: Int {
        get { 25 } // deliberately hardcoded value
        set { } // deliberately ignore new value
    }
}

/// Key type for storing the activity bar width in the `userInfo` of the related `Console` without colliding with end user keys.
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

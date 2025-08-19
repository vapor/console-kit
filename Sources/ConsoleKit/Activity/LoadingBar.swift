extension Console {
    /// Creates a new ``LoadingBar``-based ``ActivityIndicator``.
    ///
    ///     Loading [        •             ]
    ///
    /// The `•` character will bounce from left to right while the bar is active.
    ///
    /// ```swift
    /// let loadingBar = console.loadingBar(title: "Loading")
    /// try await loadingBar.withActivityIndicator {
    ///    try await Task.sleep(for: .seconds(3))
    /// }
    /// ```
    ///
    /// - parameters:
    ///     - title: Title to display alongside the loading bar.
    /// - returns: An ``ActivityIndicator`` that can start and stop the loading bar.
    public func loadingBar(title: String) -> ActivityIndicator<LoadingBar> {
        return LoadingBar(title: title).newActivity(for: self)
    }
}

/// Loading-style implementation of ``ActivityBar``.
///
///     Loading [        •             ]
///
/// The `•` character will bounce from left to right while the bar is active.
///
/// See ``Console/loadingBar(title:)`` to create one.
public struct LoadingBar: ActivityBar {
    /// See ``ActivityBar``.
    public let title: String

    /// See ``ActivityBar``.
    public func renderActiveBar(tick: UInt, width: Int) -> ConsoleText {
        let period = width - 1
        let offset = Int(tick) % period
        let reverse = Int(tick) % (period * 2) >= period

        let increasing = offset
        let decreasing = width - offset - 1

        let left: Int
        let right: Int
        if reverse {
            left = decreasing
            right = increasing
        } else {
            left = increasing
            right = decreasing
        }

        var barComponents: [String] = []
        barComponents.append("[")
        barComponents.append(.init(repeating: " ", count: left))
        barComponents.append("•")
        barComponents.append(.init(repeating: " ", count: right))
        barComponents.append("]")
        return barComponents.joined(separator: "").consoleText(.info)
    }
}

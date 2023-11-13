import Dispatch

extension Console {
    /// Creates a new `LoadingBar`-based `ActivityIndicator`.
    ///
    ///     Loading [        •             ]
    ///
    /// The `•` character will bounce from left to right while the bar is active.
    ///
    ///     let loadingBar = console.loadingBar(title: "Loading")
    ///     background {
    ///         // complete the loading bar after 3 seconds
    ///         console.wait(seconds: 3)
    ///         loadingBar.succeed()
    ///     }
    ///     // start the loading bar and wait for it to finish
    ///     try loadingBar.start(on: ...).wait()
    ///
    /// - parameters:
    ///     - title: Title to display alongside the loading bar.
    /// - returns: An `ActivityIndicator` that can start and stop the loading bar.
    public func loadingBar(title: String, targetQueue: DispatchQueue? = nil) -> ActivityIndicator<LoadingBar> {
        return LoadingBar(title: title).newActivity(for: self, targetQueue: targetQueue)
    }
}

/// Loading-style implementation of `ActivityBar`.
///
///     Loading [        •             ]
///
/// The `•` character will bounce from left to right while the bar is active.
///
/// See `Console.loadingBar(title:)` to create one.
public struct LoadingBar: ActivityBar {
    /// See `ActivityBar`.
    public var title: String

    /// See `ActivityBar`.
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

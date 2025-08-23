extension Console {
    /// Creates a new ``ProgressBar``-based ``ActivityIndicator``.
    ///
    ///     Downloading [========                ]
    ///
    /// The `=` characters represent the value of ``ProgressBar/currentProgress`` from 0...1
    ///
    /// ```swift
    /// let progressBar = console.progressBar(title: "Downloading")
    /// try await progressBar.withActivityIndicator {
    ///     while true {
    ///         if progressBar.activity.currentProgress >= 1.0 {
    ///             return
    ///         } else {
    ///             progressBar.activity.currentProgress += 0.1
    ///             try await Task.sleep(for: .seconds(0.25))
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - parameters:
    ///     - title: Title to display alongside the loading bar.
    /// - returns: An ``ActivityIndicator`` that can start and stop the loading bar.
    public func progressBar(title: String) -> ActivityIndicator<ProgressBar> {
        return ProgressBar(title: title, currentProgress: 0).newActivity(for: self)
    }
}

/// Progress-style implementation of ``ActivityBar``.
///
///     Downloading [========                ]
///
/// The `=` characters represent the value of ``ProgressBar/currentProgress`` from 0...1
///
/// See ``Console/progressBar(title:)`` to create one.
public struct ProgressBar: ActivityBar {
    /// See ``ActivityBar``.
    public let title: String

    /// Controls how the ``ProgressBar`` is rendered.
    ///
    /// Valid values are between 0 and 1.
    ///
    /// When `1`, the progress bar is full. When `0`, it is empty.
    public var currentProgress: Double

    /// See ``ActivityBar``.
    public func renderActiveBar(tick: UInt, width: Int) -> ConsoleText {
        let current = min(max(currentProgress, 0.0), 1.0)

        let left = Int(current * Double(width))
        let right = width - left

        var barComponents: [String] = []
        barComponents.append("[")
        barComponents.append(.init(repeating: "=", count: Int(left)))
        barComponents.append(.init(repeating: " ", count: Int(right)))
        barComponents.append("]")
        return barComponents.joined(separator: "").consoleText(.info)
    }
}

extension ActivityIndicator where A == ProgressBar {
    /// Starts the ``ActivityIndicator`` with a default refresh rate of 40 milliseconds.
    ///
    /// This method is a convenience wrapper around ``ActivityIndicator/withActivityIndicator(refreshRate:_:)-(_,()->T)``.
    /// It passes the progress bar to the body closure, allowing you to update the `currentProgress` property as needed.
    ///
    /// ```swift
    /// try await console.progressBar(title: "Downloading").withActivityIndicator { progressBar in
    ///     while true {
    ///         if progressBar.activity.currentProgress >= 1.0 {
    ///             return
    ///         } else {
    ///             progressBar.activity.currentProgress += 0.1
    ///             try await Task.sleep(for: .seconds(0.25))
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// See ``ActivityIndicator/withActivityIndicator(refreshRate:_:)-(_,()->T)`` for more information.
    @discardableResult
    public func withActivityIndicator<T>(
        refreshRate: Int = 40,
        _ body: @Sendable (ActivityIndicator<ProgressBar>) async throws -> T
    ) async rethrows -> T {
        return try await self.withActivityIndicator(refreshRate: refreshRate) {
            try await body(self)
        }
    }
}

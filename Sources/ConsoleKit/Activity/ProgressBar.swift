import Dispatch

extension Console {
    /// Creates a new `ProgressBar`-based `ActivityIndicator`.
    ///
    ///     Downloading [========                ]
    ///
    /// The `=` characters represent the value of `ProgressBar.currentProgress` from 0...1
    ///
    ///     let progressBar = console.progressBar(title: "Downloading")
    ///     background {
    ///         // increment the progress bar by 10% every 1/4 second
    ///         // once progress is 100%, trigger success
    ///         while true {
    ///             if progressBar.activity.currentProgress >= 1 { break }
    ///             progressBar.activity.currentProgress += 0.1
    ///             console.wait(seconds: 0.25)
    ///         }
    ///         progressBar.succeed()
    ///     }
    ///     // start the progress bar and wait for it to finish
    ///     try progressBar.start(on: ...).wait()
    ///
    /// - parameters:
    ///     - title: Title to display alongside the loading bar.
    /// - returns: An `ActivityIndicator` that can start and stop the loading bar.
    public func progressBar(title: String, targetQueue: DispatchQueue? = nil) -> ActivityIndicator<ProgressBar> {
        return ProgressBar(title: title, currentProgress: 0).newActivity(for: self, targetQueue: targetQueue)
    }
}

/// Progress-style implementation of `ActivityBar`.
///
///     Downloading [========                ]
///
/// The `=` characters represent the value of `ProgressBar.currentProgress` from 0...1
///
/// See `Console.progressBar(title:)` to create one.
public struct ProgressBar: ActivityBar {
    /// See `ActivityBar`.
    public var title: String

    /// Controls how the `ProgressBar` is rendered.
    ///
    /// Valid values are between 0 and 1.
    ///
    /// When `1`, the progress bar is full. When `0`, it is empty.
    public var currentProgress: Double

    /// See `ActivityBar`.
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

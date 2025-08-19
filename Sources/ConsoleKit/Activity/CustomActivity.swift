extension Console {
    /// Creates an activity indicator with custom frames that are iterated over.
    ///
    /// ```swift
    /// // Create an activity indicator with the strings (frames) to loop over as it runs.
    /// let indicator = console.activity(title: "Loading", frames: ["⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"])
    ///
    /// try await indicator.withActivityIndicator {
    ///     // complete the indicator after 3 seconds
    ///     try await Task.sleep(for: .seconds(3))
    /// }
    /// ```
    ///
    /// > Note: If you want some ideas for indicator styles, take a look here:
    ///   https://github.com/kiliankoe/CLISpinner/blob/master/Sources/CLISpinner/Pattern.swift#L88-L151
    ///
    /// - Parameters:
    ///   - title: The title of the activity indicator.
    ///   - titleAfterIndicator: If `true`, the title of the activity indicator will be printed after the indicator itself.
    ///   - frames: The strings to loop over as the activity indicator runs.
    ///   - success: The string to replace the indicator with when the operation succeeds. The default value is `[Done]`.
    ///   - failure: The string to replace the indicator with when the operation fails: The default value is `[Failed]`.
    ///   - color: The color of text when the frames are displayed. The default value is ``ConsoleColor/cyan``.
    ///
    /// - Returns: An ``ActivityIndicator`` that can start and stop the indicator.
    public func customActivity(
        title: String,
        titleAfterIndicator: Bool = true,
        frames: [String],
        success: String = "[Done]",
        failure: String = "[Failed]",
        color: ConsoleColor = .cyan
    ) -> ActivityIndicator<CustomActivity> {
        return CustomActivity(
            title: title,
            titleAfterIndicator: titleAfterIndicator,
            frames: frames,
            success: success,
            failure: failure,
            color: color
        ).newActivity(for: self)
    }

    /// Creates an activity indicator with custom frames that are iterated over.
    ///
    /// ```swift
    /// // Create an activity indicator with the strings (frames) to loop over as it runs.
    /// let indicator = console.activity(title: "Loading", frames: ["⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"])
    ///
    /// try await indicator.withActivityIndicator {
    ///     // complete the indicator after 3 seconds
    ///     try await Task.sleep(for: .seconds(3))
    /// }
    /// ```
    ///
    /// > Note: If you want some ideas for indicator styles, take a look here:
    ///   https://github.com/kiliankoe/CLISpinner/blob/master/Sources/CLISpinner/Pattern.swift#L88-L151
    ///
    /// - Parameters:
    ///   - title: The title of the activity indicator.
    ///   - titleAfterIndicator: If `true`, the title of the activity indicator will be printed after the indicator itself.
    ///   - frames: The text to loop over as the activity indicator runs.
    ///   - success: The string to replace the indicator with when the operation succeeds. The default value is `[Done]`.
    ///   - failure: The string to replace the indicator with when the operation fails: The default value is `[Failed]`.
    ///
    /// - Returns: An ``ActivityIndicator`` that can start and stop the indicator.
    public func customActivity(
        title: String,
        titleAfterIndicator: Bool = true,
        frames: [ConsoleText],
        success: String = "[Done]",
        failure: String = "[Failed]"
    ) -> ActivityIndicator<CustomActivity> {
        return CustomActivity(
            title: title,
            titleAfterIndicator: titleAfterIndicator,
            frames: frames,
            success: success,
            failure: failure
        ).newActivity(for: self)
    }
}

/// An activity indicator with customizable frames and success and failure messages.
///
/// See ``Console/customActivity(title:titleAfterIndicator:frames:success:failure:color:)`` to make one.
public struct CustomActivity: ActivityIndicatorType {
    /// The title of the activity indicator.
    public let title: String

    /// If `true`, the title of the activity indicator will be printed after the indicator itself.
    /// If `false`, the title will be printed before the indicator.
    public let titleAfterIndicator: Bool

    /// The text that will be output on the indicator ticks, each frame corresponding to a single tick in a range of `0...(frames.count - 1)`.
    ///
    /// The index of the current frame is figured using the equation `tick % frames.count`, allowing the indicator to run indefinitely.
    public let frames: [ConsoleText]

    /// The text to be output with the ``ActivityIndicatorState/success`` style if the indicator is succeeded.
    public let success: String

    /// The text to be output with the ``ActivityIndicatorState/failure`` style if the indicator is failed.
    public let failure: String

    /// Creates a new ``CustomActivity`` instance.
    ///
    /// - Parameters:
    ///   - title: The title of the activity indicator.
    ///   - titleAfterIndicator: If `true`, the title of the activity indicator will be printed after the indicator itself.
    ///   - frames: The text to loop over as the activity indicator runs.
    ///   - success: The string to replace the indicator with when the operation succeeds. The default value is `[Done]`.
    ///   - failure: The string to replace the indicator with when the operation fails: The default value is `[Failed]`.
    public init(
        title: String,
        titleAfterIndicator: Bool = true,
        frames: [ConsoleText],
        success: String = "[Done]",
        failure: String = "[Failed]"
    ) {
        self.title = title
        self.titleAfterIndicator = titleAfterIndicator
        self.frames = frames.count > 0 ? frames : ["".consoleText(color: .cyan)]
        self.success = success
        self.failure = failure
    }

    /// Creates a new ``CustomActivity`` instance.
    ///
    /// - Parameters:
    ///   - title: The title of the activity indicator.
    ///   - titleAfterIndicator: If `true`, the title of the activity indicator will be printed after the indicator itself.
    ///   - frames: The strings to loop over as the activity indicator runs.
    ///   - success: The string to replace the indicator with when the operation succeeds. The default value is `[Done]`.
    ///   - failure: The string to replace the indicator with when the operation fails: The default value is `[Failed]`.
    ///   - color: The color of text when the frames are displayed. The default value is `.cyan`.
    public init(
        title: String,
        titleAfterIndicator: Bool = true,
        frames: [String],
        success: String = "[Done]",
        failure: String = "[Failed]",
        color: ConsoleColor = .cyan
    ) {
        self.init(
            title: title,
            titleAfterIndicator: titleAfterIndicator,
            frames: frames.map { $0.consoleText(color: color) },
            success: success,
            failure: failure
        )
    }

    /// See ``ActivityIndicatorType/outputActivityIndicator(to:state:)``.
    public func outputActivityIndicator(to console: any Console, state: ActivityIndicatorState) {
        let indicator: ConsoleText =
            switch state {
            case .ready: frames[0]
            case .active(let tick): frames[Int(tick) % frames.count]
            case .success: self.success.consoleText(.success)
            case .failure: self.failure.consoleText(.error)
            }

        titleAfterIndicator
            ? console.output(indicator + " " + title.consoleText(.plain))
            : console.output(title.consoleText(.plain) + " " + indicator)
    }
}

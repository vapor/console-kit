extension Console {
    
    /// Creates an activity indicator with custom frames that are iterated over.
    ///
    ///     // Create an activity indicator with the strings (frames) to loop over as it runs.
    ///     let indicator = console.activity(frames: ["⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"])
    ///
    ///     background {
    ///         // complete the indicator after 3 seconds
    ///         console.wait(seconds: 3)
    ///         indicator.succeed()
    ///     }
    ///     // start the indicator and wait for it to finish
    ///     try indicator.start(on: ...).wait()
    ///
    /// - Note: If you want some ideas for indicator styles, take a look here:
    ///   https://github.com/kiliankoe/CLISpinner/blob/master/Sources/CLISpinner/Pattern.swift#L88-L151
    ///
    /// - Parameters:
    ///   - frames: The strings to loop over as the activity indicator runs.
    ///   - success: The string to replace the indicator with when the operation succeeds. The default value is `[Done]`.
    ///   - failure: The string to replace the indicator with when the operation fails: The default value is `[Failed]`.
    ///   - color: The color of text when the frames are displayed. The default value is `.cyan`.
    ///
    /// - Returns: An `ActivityIndicator` that can start and stop the indicator.
    public func customActivity(
        frames: [String], success: String = "[Done]", failure: String = "[Failed]", color: ConsoleColor = .cyan
    ) -> ActivityIndicator<CustomActivity> {
        return CustomActivity(frames: frames, success: success, failure: failure, color: color).newActivity(for: self)
    }
    
    /// Creates an activity indicator with custom frames that are iterated over.
    ///
    ///     // Create an activity indicator with the strings (frames) to loop over as it runs.
    ///     let indicator = console.activity(frames: ["⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"])
    ///
    ///     background {
    ///         // complete the indicator after 3 seconds
    ///         console.wait(seconds: 3)
    ///         indicator.succeed()
    ///     }
    ///     // start the indicator and wait for it to finish
    ///     try indicator.start(on: ...).wait()
    ///
    /// - Note: If you want some ideas for indicator styles, take a look here:
    ///   https://github.com/kiliankoe/CLISpinner/blob/master/Sources/CLISpinner/Pattern.swift#L88-L151
    ///
    /// - Parameters:
    ///   - frames: The text to loop over as the activity indicator runs.
    ///   - success: The string to replace the indicator with when the operation succeeds. The default value is `[Done]`.
    ///   - failure: The string to replace the indicator with when the operation fails: The default value is `[Failed]`.
    ///
    /// - Returns: An `ActivityIndicator` that can start and stop the indicator.
    public func customActivity(
        frames: [ConsoleText], success: String = "[Done]", failure: String = "[Failed]"
    ) -> ActivityIndicator<CustomActivity> {
        return CustomActivity(frames: frames, success: success, failure: failure).newActivity(for: self)
    }
}

/// An activity indicator with customizable frames and success and failure messages.
///
/// See `Console.activity(frames:success:failure:color:)` to make one.
public struct CustomActivity: ActivityIndicatorType {
    
    /// The text that will be output on the indicator ticks, each frame corresponding to a single tick in a range of `0...(frames.count - 1)`.
    ///
    /// The index of the current frame is figured using the equation `tick % frames.count`, allowing the indicator to run indefinitely.
    public let frames: [ConsoleText]
    
    /// The text to be output with the `.success` style if the indicator is succeeded.
    public let success: String
    
    /// The text to be output with the `.error` style if the indicator is failed.
    public let failure: String
    
    
    /// Creates a new `CustomActivityIndicator` instance.
    ///
    /// - Parameters:
    ///   - frames: The text to loop over as the activity indicator runs.
    ///   - success: The string to replace the indicator with when the operation succeeds. The default value is `[Done]`.
    ///   - failure: The string to replace the indicator with when the operation fails: The default value is `[Failed]`.
    public init(frames: [ConsoleText], success: String = "[Done]", failure: String = "[Failed]") {
        self.frames = frames.count > 0 ? frames : ["".consoleText(color: .cyan)]
        self.success = success
        self.failure = failure
    }
    
    /// Creates a new `CustomerActivityIndicator` instance.
    ///
    /// - Parameters:
    ///   - frames: The strings to loop over as the activity indicator runs.
    ///   - success: The string to replace the indicator with when the operation succeeds. The default value is `[Done]`.
    ///   - failure: The string to replace the indicator with when the operation fails: The default value is `[Failed]`.
    ///   - color: The color of text when the frames are displayed. The default value is `.cyan`.
    public init(frames: [String], success: String = "[Done]", failure: String = "[Failed]", color: ConsoleColor = .cyan) {
        self.init(frames: frames.map { $0.consoleText(color: color) }, success: success, failure: failure)
    }
    
    
    /// See `ActivityIndicatorType.outputActivityIndicator(to:state:)`.
    public func outputActivityIndicator(to console: any Console, state: ActivityIndicatorState) {
        let output: ConsoleText
        
        switch state {
        case .ready: output = frames[0]
        case let .active(tick): output = frames[Int(tick) % frames.count]
        case .success: output = self.success.consoleText(.success)
        case .failure: output = self.failure.consoleText(.error)
        }
        
        console.output(output)
    }
}

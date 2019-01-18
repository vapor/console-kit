import NIO

extension ActivityIndicatorType {
    /// Creates a new `ActivityIndicator` for this `ActivityIndicatorType`.
    ///
    /// See `ActivityIndicator` for more information.
    ///
    /// - parameters:
    ///     - console: Console to use for rendering the `ActivityIndicator`
    public func newActivity(for console: Console) -> ActivityIndicator<Self> {
        return .init(activity: self, console: console)
    }
}

/// An instance of a `ActivityIndicatorType` that can be started, failed, and succeeded.
///
/// Use `newActivity(for:)` on `ActivityIndicatorType` to create one.
///
///     let loadingBar = console.loadingBar(title: "Loading")
///     background {
///         // complete the loading bar after 3 seconds
///         console.blockingWait(seconds: 3)
///         loadingBar.succeed()
///     }
///     // start the loading bar and wait for it to finish
///     try loadingBar.start(on: ...).wait()
///
public final class ActivityIndicator<A> where A: ActivityIndicatorType {
    /// The generic `ActivityIndicatorType` powering this `ActivityIndicator`.
    public var activity: A

    /// The `Console` this `ActivityIndicator` is running on.
    private let console: Console

    /// Current state.
    private var state: ActivityIndicatorState
    
    private var task: RepeatedTask?
    
    private var promise: EventLoopPromise<Void>?
    
    private let eventLoop: EventLoop

    /// Creates a new `ActivityIndicator`. Use `ActivityIndicatorType.newActivity(for:)`.
    init(activity: A, console: Console) {
        self.console = console
        self.state = .ready
        self.activity = activity
        self.eventLoop = console.eventLoopGroup.next()
    }

    /// Starts the `ActivityIndicator`. Usually this means beginning the associated "loading" animation.
    ///
    /// Once started, `ActivityIndicator` will continue to redraw the `ActivityIndicatorType` at a fixed
    /// refresh rate passing `ActivityIndicatorState.active`.
    ///
    /// - returns: A `Future` that completes when the `ActivityIndicator` is finished (fail or succeed).
    public func start() -> EventLoopFuture<Void> {
        let promise = self.eventLoop.makePromise(of: Void.self)
        var tick: UInt = 0
        self.task = self.eventLoop.scheduleRepeatedTask(initialDelay: .seconds(0), delay: .milliseconds(40)) { task -> Void in
            if tick > 0 {
                self.console.popEphemeral()
            }
            self.console.pushEphemeral()
            self.activity.outputActivityIndicator(to: self.console, state: .active(tick: tick))
            tick = tick &+ 1
        }
        self.promise = promise
        return promise.futureResult
    }

    /// Stops the `ActivityIndicator`, yielding a failed / error appearance.
    ///
    /// Passes `ActivityIndicatorState.failure` to the `ActivityIndicatorType`.
    ///
    /// Must be called after `start(on:)` and completes the future returned by that method.
    public func fail() {
        stop()
        activity.outputActivityIndicator(to: console, state: .failure)
    }

    /// Stops the `ActivityIndicator`, yielding a success / done appearance.
    ///
    /// Passes `ActivityIndicatorState.success` to the `ActivityIndicatorType`.
    ///
    /// Must be called after `start(on:)` and completes the future returned by that method.
    public func succeed() {
        stop()
        activity.outputActivityIndicator(to: console, state: .success)
    }

    /// Stops the output refreshing and clears the console.
    private func stop() {
        self.task!.cancel()
        self.promise!.succeed(result: ())
        console.popEphemeral()
    }
}

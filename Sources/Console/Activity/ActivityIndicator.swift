import Dispatch

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
    public var activity: A
    private let console: Console
    private var state: ActivityIndicatorState
    private var background: DispatchWorkItem?
    private var isActive: Bool

    init(activity: A, console: Console) {
        self.console = console
        self.state = .ready
        self.activity = activity
        self.isActive = false
    }

    public func start(on worker: Worker) -> Future<Void> {
        isActive = true
        let promise = worker.eventLoop.newPromise(Void.self)
        let background = DispatchWorkItem {
            var tick: UInt = 0
            while self.isActive {
                defer { tick = tick &+ 1 }
                if tick > 0 {
                    self.console.popEphemeral()
                }
                self.console.pushEphemeral()
                self.activity.outputActivityIndicator(to: self.console, state: .active(tick: tick))
                self.console.blockingWait(seconds: 0.04)
            }
            promise.succeed()
        }

        DispatchQueue.global().async(execute: background)
        self.background = background
        return promise.futureResult
    }

    public func fail() {
        stop()
        activity.outputActivityIndicator(to: console, state: .fail)
    }

    public func succeed() {
        stop()
        activity.outputActivityIndicator(to: console, state: .done)
    }

    private func stop() {
        isActive = false
        console.popEphemeral()
        background?.cancel()
        background = nil
    }
}

#if !canImport(Darwin)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif
import NIOConcurrencyHelpers

extension ActivityIndicatorType {
    /// Creates a new `ActivityIndicator` for this `ActivityIndicatorType`.
    ///
    /// See `ActivityIndicator` for more information.
    ///
    /// - parameters:
    ///     - console: Console to use for rendering the `ActivityIndicator`
    ///     - targetQueue: An optional target queue (defaults to `nil`) on which
    ///                    asynchronous updates to the console will be
    ///                    scheduled.
    public func newActivity(for console: any Console, targetQueue: DispatchQueue? = nil) -> ActivityIndicator<Self> {
        return .init(activity: self, console: console, targetQueue: targetQueue)
    }
}

/// An instance of a `ActivityIndicatorType` that can be started, failed, and succeeded.
///
/// Use `newActivity(for:)` on `ActivityIndicatorType` to create one.
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
public final class ActivityIndicator<A>: Sendable where A: ActivityIndicatorType {
    let _activity: NIOLockedValueBox<A>
    /// The generic `ActivityIndicatorType` powering this `ActivityIndicator`.
    public var activity: A {
        get {
            self._activity.withLockedValue { $0 }
        }
        set {
            self._activity.withLockedValue { $0 = newValue }
        }
    }

    /// The `Console` this `ActivityIndicator` is running on.
    private let console: any Console
    
    /// The queue on which to handle timer events
    private let queue: DispatchQueue
    
    /// We use a DispatchGroup as a synchronization mechanism for when the
    /// dispatch timer is cancelled.
    private let stopGroup: DispatchGroup
    
    private let _timer: NIOLockedValueBox<any DispatchSourceTimer & Sendable>
    /// The timer that drives this activity indicator's updates.
    private var timer: any DispatchSourceTimer & Sendable {
        get {
            self._timer.withLockedValue { $0 }
        }
        
        set {
            self._timer.withLockedValue { $0 = newValue }
        }
    }
    
    /// Creates a new `ActivityIndicator`. Use `ActivityIndicatorType.newActivity(for:)`.
    init(activity: A, console: any Console, targetQueue: DispatchQueue? = nil) {
        self.console = console
        self._activity = NIOLockedValueBox(activity)
        self.queue = DispatchQueue(label: "codes.vapor.consolekit.activityindicator", target: targetQueue)

        let timer = DispatchSource.makeTimerSource(flags: [], queue: self.queue) as! DispatchSource
        // Activate the timer in case the activity indicator is never started
        timer.activate()
        self._timer = NIOLockedValueBox(timer)
        
        self.stopGroup = DispatchGroup()
    }

    /// Starts the `ActivityIndicator`. Usually this means beginning the associated "loading" animation.
    ///
    /// Once started, `ActivityIndicator` will continue to redraw the `ActivityIndicatorType` at a fixed
    /// refresh rate passing `ActivityIndicatorState.active`.
    ///
    /// - Parameters:
    ///     - refreshRate: The time interval (specified in milliseconds) to use
    ///                    when updating the activity.
    public func start(refreshRate: Int = 40) {
        guard console.supportsANSICommands else {
            // Skip animations if the console does not support ANSI commands
            self.activity.outputActivityIndicator(to: self.console, state: .ready)
            return
        }

        self.timer.schedule(
            deadline: DispatchTime.now(),
            repeating: .milliseconds(refreshRate),
            leeway: DispatchTimeInterval.milliseconds(10)
        )
        
        var tick: UInt = 0
        self.timer.setEventHandler { [unowned self] in
            if tick > 0 {
                self.console.popEphemeral()
            }
            tick = tick &+ 1
            self.console.pushEphemeral()
            self.activity.outputActivityIndicator(to: self.console, state: .active(tick: tick))
        }
        
        self.stopGroup.enter()
        self.timer.setCancelHandler { [unowned self] in
            if tick > 0 {
                self.console.popEphemeral()
            }
            self.stopGroup.leave()
        }
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
    ///
    /// - Precondition: `start()` must have been called once before this.
    /// - Postcondition: The indicator is idle, and safe to be interacted with
    ///                  from the main thread (e.g. to call
    ///                  `activity.outputActivityIndicator(to:state:)` as with
    ///                  the public `fail()` and `succeed()` implementations.
    private func stop() {
        self.timer.cancel()
        self.stopGroup.wait()
        self.timer.setEventHandler {}
        self.timer.setCancelHandler {}
    }
}

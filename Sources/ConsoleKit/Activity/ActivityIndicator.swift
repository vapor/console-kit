import AsyncAlgorithms
import Synchronization

extension ActivityIndicatorType {
    /// Creates a new ``ActivityIndicator`` for this ``ActivityIndicatorType``.
    ///
    /// See ``ActivityIndicator`` for more information.
    ///
    /// - parameter console: Console to use for rendering the ``ActivityIndicator``
    public func newActivity(for console: any Console) -> ActivityIndicator<Self> {
        return .init(activity: self, console: console)
    }
}

/// An instance of a ``ActivityIndicatorType`` that can be started, failed, and succeeded.
///
/// Use ``ActivityIndicatorType/newActivity(for:)`` on ``ActivityIndicatorType`` to create one.
///
/// ```swift
/// let loadingBar = console.loadingBar(title: "Loading")
/// try await foo.withActivityIndicator {
///     try await Task.sleep(for: .seconds(2.5))
/// }
/// ```
///
public final class ActivityIndicator<A>: Sendable where A: ActivityIndicatorType {
    let _activity: Mutex<A>
    /// The generic `ActivityIndicatorType` powering this `ActivityIndicator`.
    public var activity: A {
        get {
            self._activity.withLock { $0 }
        }
        set {
            self._activity.withLock { $0 = newValue }
        }
    }

    /// The `Console` this `ActivityIndicator` is running on.
    private let console: any Console

    /// Creates a new `ActivityIndicator`. Use `ActivityIndicatorType.newActivity(for:)`.
    init(activity: A, console: any Console) {
        self.console = console
        self._activity = Mutex(activity)
    }

    /// Starts the `ActivityIndicator`. Usually this means beginning the associated "loading" animation.
    ///
    /// Once started, `ActivityIndicator` will continue to redraw the `ActivityIndicatorType` at a fixed
    /// refresh rate passing `ActivityIndicatorState.active`.
    ///
    /// - Parameters:
    ///     - refreshRate: The time interval (specified in milliseconds) to use
    ///                    when updating the activity.
    private func start(refreshRate: Int = 40) async {
        guard console.supportsANSICommands else {
            // Skip animations if the console does not support ANSI commands
            self.activity.outputActivityIndicator(to: self.console, state: .ready)
            return
        }

        let timer = AsyncTimerSequence(
            interval: .milliseconds(refreshRate),
            tolerance: .milliseconds(10),
            clock: .continuous
        )

        var tick: UInt = 0

        defer {
            if tick > 0 {
                self.console.popEphemeral()
            }
        }

        for await _ in timer {
            if tick > 0 {
                self.console.popEphemeral()
            }
            tick = tick &+ 1
            self.console.pushEphemeral()
            self.activity.outputActivityIndicator(to: self.console, state: .active(tick: tick))
        }
    }

    /// Stops the `ActivityIndicator`, yielding a failed / error appearance.
    ///
    /// Passes `ActivityIndicatorState.failure` to the `ActivityIndicatorType`.
    ///
    /// Must be called after `start(on:)` and completes the future returned by that method.
    private func fail() {
        activity.outputActivityIndicator(to: console, state: .failure)
    }

    /// Stops the `ActivityIndicator`, yielding a success / done appearance.
    ///
    /// Passes `ActivityIndicatorState.success` to the `ActivityIndicatorType`.
    ///
    /// Must be called after `start(on:)` and completes the future returned by that method.
    private func succeed() {
        activity.outputActivityIndicator(to: console, state: .success)
    }

    /// Starts the ``ActivityIndicator`` and stops it after the provided body completes.
    ///
    /// The body must return a `Bool` indicating whether the activity was successful or not.
    ///
    /// - Parameters:
    ///   - refreshRate: The time interval (specified in milliseconds) to use when updating the activity.
    ///   - body: The asynchronous body to execute while the activity indicator is running.
    @discardableResult
    public func withActivityIndicator<T>(refreshRate: Int = 40, _ body: () async throws -> T) async rethrows -> T {
        let task = Task {
            await self.start(refreshRate: refreshRate)
        }

        do {
            let result = try await body()
            task.cancel()
            self.succeed()
            return result
        } catch {
            task.cancel()
            self.fail()
            throw error
        }
    }
}

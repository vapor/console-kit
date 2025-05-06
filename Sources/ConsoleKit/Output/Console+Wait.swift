import Foundation

extension Console {
    /// Blocks the current thread for the specified number of seconds.
    ///
    ///     console.wait(seconds: 3.14)
    ///
    /// - warning: Do not use this method on an `EventLoop`. It is for testing purposes only.
    ///
    /// - parameters:
    ///     - seconds: The number of seconds to wait for.
    public func wait(seconds: Double) {
        Thread.sleep(forTimeInterval: seconds)
    }
}

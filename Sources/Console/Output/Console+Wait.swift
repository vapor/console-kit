import COperatingSystem

extension Console {
    /// Blocks the current thread for the specified number of seconds.
    ///
    ///     console.blockingWait(seconds: 3.14)
    ///
    /// - warning: Do not use this method on an `EventLoop`. It is for testing purposes only.
    ///
    /// - parameters:
    ///     - seconds: The number of seconds to wait for.
    public func blockingWait(seconds: Double) {
        let factor = 1000 * 1000
        let microseconds = seconds * Double(factor)
        usleep(useconds_t(microseconds))
    }
}

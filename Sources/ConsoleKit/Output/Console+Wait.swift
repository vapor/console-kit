#if os(Linux)
import Glibc
#else
import Darwin
#endif

extension Console {
    /// Blocks the current thread for the specified number of seconds.
    ///
    ///     console.wait(seconds: 3)
    ///
    /// - warning: Do not use this method on an `EventLoop`. It is for testing purposes only.
    ///
    /// - parameters:
    ///     - seconds: The number of seconds to wait for.
    public func wait(seconds: Int) {
        sleep(numericCast(seconds))
    }
    
    /// Blocks the current thread for the specified number of seconds.
    ///
    ///     console.blockingWait(seconds: 3.14)
    ///
    /// - warning: Do not use this method on an `EventLoop`. It is for testing purposes only.
    ///
    /// - parameters:
    ///     - seconds: The number of seconds to wait for.
    public func wait(microseconds: Int) {
        usleep(numericCast(microseconds))
    }
}

// This implementation is only used on Linux, but we enable building it on macOS in debug for testing purposes.
#if (os(Linux) || os(Android)) || (os(macOS) && DEBUG)
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Android)
import Android
#elseif canImport(Musl)
import Musl
#endif
import Dispatch

/// This implementation of `readpassphrase()`, used only on Linux where it's extremely difficult to get at the `libbsd`
/// API even when it is definitely present, is even less tolerant of being called on multiple threads at once than the
/// original. It was already never sensible to do so in any case; the interface doesn't have enough smarts to be able to
/// interact with arbitrary terminals - it can only deal with `/dev/tty`. `libbsd`'s version will just fall on the floor
/// and make an interesting mess of the process signal handlers if one tries it. This version does it one better: It's a
/// fatal error to call it off the main thread. This enables us to have the signal recovery handler write to somewhere
/// it can find without risking intervention from the Swift runtime at async-signal time.
internal func linux_readpassphrase(_ prompt: UnsafePointer<Int8>, _ buf: UnsafeMutablePointer<Int8>, _ bufsiz: Int, _ flags: Int32) -> UnsafeMutablePointer<Int8>? {
    //dispatchPrecondition(condition: .onQueue(.main))
    
    precondition((flags & 0x20/* RPP_STDIN */) == 0, "RPP_STDIN is not supported by this implementation")
    precondition((flags & 0x04/* RPP_FORCELOWER */) == 0, "RPP_FORCELOWER is not supported by this implementation")
    precondition((flags & 0x08/* RPP_FORCEUPPER */) == 0, "RPP_FORCEUPPER is not supported by this implementation")
    precondition((flags & 0x10/* RPP_SEVENBIT */) == 0, "RPP_SEVENBIT is not supported by this implementation")
    
    #if !canImport(Darwin)
    let TCSASOFT = 0 as Int32
    #endif
    
    // Open /dev/tty
    let fd = open("/dev/tty", O_RDWR)
    guard fd >= 0 else { return nil }
    defer { close(fd) }
    
    // Disable echo
    var oterm = termios(), term = termios()
    guard tcgetattr(fd, &oterm) == 0 else { return nil }
    term = oterm
    if (flags & 0x1/* RPP_ECHO_ON */) == 0 {
        term.c_lflag &= tcflag_t(bitPattern: numericCast(~(ECHO | ECHONL)))
    }
    _ = tcsetattr(fd, TCSAFLUSH | TCSASOFT, &term) // libbsd ignores it if this calls fails, should we be doing the same?
    
    // Reset the signal counts and install a recovery handler onto a whole buncha signals
    linux_readpassphrase_signos.reset()
    var sigrecovery = sigaction(), sigsave = sigaction(), sigsaves: [Int32: sigaction] = [
        SIGALRM: .init(),   SIGHUP: .init(),    SIGINT: .init(),    SIGPIPE: .init(),   SIGQUIT: .init(),
        SIGTERM: .init(),   SIGTSTP: .init(),   SIGTTIN: .init(),   SIGTTOU: .init(),
    ]
    sigemptyset(&sigrecovery.sa_mask)
    sigrecovery.sa_flags = 0
    #if canImport(Darwin)
    sigrecovery.__sigaction_u = .init(__sa_handler: { linux_readpassphrase_signos[$0] += 1 })
    #elseif canImport(Glibc)
    sigrecovery.__sigaction_handler = .init(sa_handler: { linux_readpassphrase_signos[$0] += 1 })
    #elseif canImport(Musl)
    sigrecovery.__sa_handler = .init(sa_handler: { linux_readpassphrase_signos[$0] += 1 })
    #elseif os(Android)
    sigrecovery.sa_handler = { linux_readpassphrase_signos[$0] += 1 }
    #endif
    for (sig, _) in sigsaves { sigaction(sig, &sigrecovery, &sigsave); sigsaves[sig] = sigsave }
    
    // Loop over a read() call, character by character. At the end, null-terminate. If echo is disabled, write a newline.
    var i = 0, nr = 1, save_errno = 0 as Int32
    var c: Int8 = 0
    while i < bufsiz - 1 && nr == 1 && c != 0x0a && c != 0x0d {
        nr = read(fd, &c, 1)
        if nr == 1 { buf[i] = c; i += 1 }
    }
    buf[i] = 0
    save_errno = errno // save off errno for later restoration after the state restoration stuff below
    if (term.c_lflag & tcflag_t(bitPattern: numericCast(ECHO))) == 0 { write(fd, "\n", 1) }
    
    // Restore original terminal config
    if memcmp(&term, &oterm, MemoryLayout<termios>.size) != 0 {
        // I don't understand what this sequence accomplishes with respect to ignoring SIGTTOU.
        let save_sigttou = linux_readpassphrase_signos[SIGTTOU]
        while tcsetattr(fd, TCSAFLUSH | TCSASOFT, &oterm) == -1 && errno == EINTR && linux_readpassphrase_signos[SIGTTOU] == 0 {
            continue
        }
        linux_readpassphrase_signos[SIGTTOU] = save_sigttou
    }
    
    // Restore signal handlers
    for (sig, var sa) in sigsaves { sigaction(sig, &sa, nil) }
    
    // libbsd closes the TTY fd here. Since we deferred the fd closure, we just hope the difference doesn't cause problems.
    
    // Re-raise any signals we temporarily ignored, now that the old signal handlers are back in place.
    for i in 0..<NSIG where linux_readpassphrase_signos[i] != 0 {
        kill(getpid(), i)
        // libbsd restarts the entire readpassphrase() execution if the signal was SIGTSTP, SIGTTIN, or SIGTTOU. Using goto.
        // It makes sense functionally, but it's more trouble than it's worth for now.
    }
    
    // Return nil for a `read(2)` error.
    if save_errno != 0 {
        errno = save_errno
    }
    return nr == -1 ? nil : buf
}

/// Used for signal recovery by `linux_readpassphrase()`. This is `static volatile` storage in the original.
/// We must avoid any accesses into the Swift runtime in the signal handler, so this is manually allocated
/// storage rather than a simple array. It is never deallocated and will be considered a leak by memory
/// analysis tools.
fileprivate let linux_readpassphrase_signos: VeryUnsafeMutableSigAtomicBufferPointer = .init(capacity: NSIG)

/// A version of `UnsafeMutableBufferPointer` which avoids any references to the Swift runtime, including conformance to
/// `Collection` or `Sequence`, etc. Guaranteed to only ever allocate once. Provides a (typically global) "array" of
/// `sig_atomic_t` values suitable for use by a signal handler to communicate state changes to other code. Promises to
/// obey all async-signal-safe rules (such as reentrancy tolerance and avoidance of non-async-signal-safe library
/// functions) except during `init`. Not suitable for much else besides use by signal handlers. This is a deliberately
/// "badly" designed structure according to established Swift idioms; it eschews protocol conformances, abstractions
/// such as `Index` and `Element` typealiases, and the use of any runtime facilities _ON PURPOSE_. Do _NOT_ add such
/// things to this structure thinking that you're improving it. You're not. I promise. Most especially, don't try to
/// extend it to do things like "initialize", "bind", "move", "assign", etc. operations on memory correctly. It's wrong
/// deliberately. Swift has no other model for doing this kind of thing yet.
///
/// If you think you want to use this for something, you're wrong.
fileprivate struct VeryUnsafeMutableSigAtomicBufferPointer: @unchecked Sendable {
    let capacity: Int
    let baseAddress: UnsafeMutablePointer<sig_atomic_t>
    
    init<I: FixedWidthInteger & BinaryInteger>(capacity: I) {
        self.capacity = Int(capacity)
        self.baseAddress = .allocate(capacity: self.capacity)
    }
    
    subscript(_ index: Int) -> sig_atomic_t {
        get { self.baseAddress.advanced(by: index).pointee }
        nonmutating set { self.baseAddress.advanced(by: index).pointee = newValue }
    }

    subscript(_ index: Int32) -> sig_atomic_t {
        get { self[Int(index)] }
        nonmutating set { self[Int(index)] = newValue }
    }
    
    func reset() {
        self.baseAddress.update(repeating: 0, count: self.capacity)
    }
}
#endif


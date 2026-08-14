#if (os(Linux) || os(Android)) || (os(macOS) && DEBUG)
@testable import ConsoleKit
import Testing

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Android)
import Android
#elseif canImport(Musl)
import Musl
#endif

// Regression tests for https://github.com/swiftlang/swift/issues/91387
@Suite("readpassphrase Tests", .serialized)
struct ReadPassphraseTests {
    private func handler(of sa: sigaction) -> UInt {
        #if canImport(Darwin)
        return unsafe unsafeBitCast(sa.__sigaction_u.__sa_handler, to: UInt.self)
        #elseif canImport(Glibc)
        return unsafe unsafeBitCast(sa.__sigaction_handler.sa_handler, to: UInt.self)
        #elseif canImport(Musl)
        return unsafe unsafeBitCast(sa.__sa_handler.sa_handler, to: UInt.self)
        #elseif os(Android)
        return unsafe unsafeBitCast(sa.sa_handler, to: UInt.self)
        #endif
    }

    private func currentHandler(_ signo: Int32) -> UInt {
        var sa = sigaction()
        unsafe sigaction(signo, nil, &sa)
        return self.handler(of: sa)
    }

    private func makeRecoveryHandler() -> sigaction {
        var sa = sigaction()
        unsafe sigemptyset(&sa.sa_mask)
        sa.sa_flags = 0
        #if canImport(Darwin)
        sa.__sigaction_u = .init(__sa_handler: { _ in })
        #elseif canImport(Glibc)
        sa.__sigaction_handler = .init(sa_handler: { _ in })
        #elseif canImport(Musl)
        sa.__sa_handler = .init(sa_handler: { _ in })
        #elseif os(Android)
        sa.sa_handler = { _ in }
        #endif
        return sa
    }

    @Test("Signal list has no duplicates")
    func signalListIsUnique() {
        #expect(linux_readpassphrase_signals.count == Set(linux_readpassphrase_signals).count)
    }

    @Test("Signal dispositions are saved and restored", .bug("https://github.com/vapor/console-kit/issues/235"))
    func signalDispositionsRoundTrip() {
        let signals = linux_readpassphrase_signals
        let original = signals.map(self.currentHandler)

        var recovery = self.makeRecoveryHandler()
        let saved = linux_readpassphrase_installHandlers(signals, &recovery)

        #expect(saved.count == signals.count)

        let recoveryHandler = self.handler(of: recovery)
        for signo in signals {
            #expect(self.currentHandler(signo) == recoveryHandler, "signal \(signo) did not get the recovery handler")
        }

        linux_readpassphrase_restoreHandlers(signals, saved)

        for (signo, before) in zip(signals, original) {
            #expect(self.currentHandler(signo) == before, "signal \(signo) was not restored")
        }
    }
}
#endif

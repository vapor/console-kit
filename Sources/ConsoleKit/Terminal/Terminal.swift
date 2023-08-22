#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif os(Windows)
import CRT
#endif
import Foundation

/// Generic console that uses a mixture of Swift standard
/// library and Foundation code to fulfill protocol requirements.
public final class Terminal: Console, Sendable {
    /// See `Console`
    public var userInfo: [AnyHashable: Sendable]

    /// Dynamically exclude ANSI commands when in Xcode since it doesn't support them.
    internal var enableCommands: Bool {
        if let stylizeOverride = self.stylizedOutputOverride {
            return stylizeOverride
        }
        #if Xcode
            return false
        #else
            return isatty(STDOUT_FILENO) > 0
        #endif
    }

    /// Create a new Terminal.
    public init() {
        self.userInfo = [:]
    }

    /// See `Console`
    public func clear(_ type: ConsoleClear) {
        switch type {
        case .line:
            command(.cursorUp)
            command(.eraseLine)
        case .screen:
            command(.eraseScreen)
        }
    }

    /// See `Console`
    public func input(isSecure: Bool) -> String {
        didOutputLines(count: 1)
        if isSecure {
            var pass = ""
#if canImport(Darwin) || canImport(Glibc) || os(Android)
            func plat_readpassphrase(into buf: UnsafeMutableBufferPointer<Int8>) -> Int {
                #if canImport(Darwin)
                let rpp = readpassphrase
                #else
                let rpp = linux_readpassphrase, RPP_REQUIRE_TTY = 0 as Int32
                #endif

                while rpp("", buf.baseAddress!, buf.count, RPP_REQUIRE_TTY) == nil {
                    guard errno == EINTR else { return 0 }
                }
                return strlen(buf.baseAddress!)
            }
            func readpassphrase_str() -> String {
                if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
                    return .init(unsafeUninitializedCapacity: 1024) { $0.withMemoryRebound(to: Int8.self) { plat_readpassphrase(into: $0) } }
                } else {
                    return .init(decoding: [Int8](unsafeUninitializedCapacity: 1024) { $1 = plat_readpassphrase(into: $0) }.map(UInt8.init), as: UTF8.self)
                }
            }
            pass = readpassphrase_str()
#elseif os(Windows)
            while pass.count < 32768 { // arbitrary upper bound for sanity
                let c = _getch()
                if c == 0x0d || c == 0x0a {
                    break
                } else if isprint(c) {
                    pass.append(Character(Unicode.Scalar(c)))
                }
            }
#endif
            if pass.hasSuffix("\n") {
                pass = String(pass.dropLast())
            }
            return pass
        } else {
            guard let line = readLine(strippingNewline: true) else {
                fatalError("Received EOF on stdin; unable to read input. Stopping here.")
            }
            return line
        }
    }

    /// See `Console`
    public func output(_ text: ConsoleText, newLine: Bool) {
        if self.enableCommands {
            var lines = 0
            for fragment in text.fragments {
                let strings = fragment.string.split(separator: "\n", omittingEmptySubsequences: false)
                for string in strings {
                    let count = string.count
                    if count > size.width && count > 0 && size.width > 0 {
                        lines += (count / size.width) + 1
                    }
                }
                /// add line for each fragment
                lines += strings.count - 1
            }
            if newLine { lines += 1 }
            
            didOutputLines(count: lines)
        }

        let terminator = newLine ? "\n" : ""

        let output: String
        if enableCommands {
            output = text.terminalStylize()
        } else {
            output = text.description
        }
        Swift.print(output, terminator: terminator)
    }

    /// See `Console`
    public func report(error: String, newLine: Bool) {
        for c in (newLine ? "\(error)\n" : error).utf8 {
#if os(Windows)
            _putc_nolock(CInt(c), stderr)
#else
            putc_unlocked(CInt(c), stderr)
#endif
        }
    }

    /// See `Console`
    public var size: (width: Int, height: Int) {
        var w = winsize()
        _ = ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &w);
        return (Int(w.ws_col), Int(w.ws_row))
    }
}

extension Console {

    /// If set, overrides a `Terminal`'s own determination as to whether its
    /// output supports color commands. Useful for easily implementing an option
    /// of the form `--color=no|yes|auto`. If the active `Console` is not
    /// specifically a `Terminal`, has no effect.
    public var stylizedOutputOverride: Bool? {
        get { return self.userInfo["stylizedOutputOverride"] as? Bool }
        set { self.userInfo["stylizedOutputOverride"] = newValue }
    }

}

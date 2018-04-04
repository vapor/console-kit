/// Generic console that uses a mixture of Swift standard
/// library and Foundation code to fulfill protocol requirements.
public final class Terminal: Console {
    /// See Extendable.extend
    public var extend: Extend
    
    internal var applyStyle: Bool {
        #if Xcode
            return false
        #else
            return true
        #endif
    }

    /// Create a new Terminal.
    public init() {
        self.extend = [:]
    }

    /// See ClearableConsole.clear
    public func clear(_ type: ConsoleClear) {
        switch type {
        case .line:
            command(.cursorUp)
            command(.eraseLine)
        case .screen:
            command(.eraseScreen)
        }
    }

    /// See InputConsole.input
    public func input(isSecure: Bool) -> String {
        didOutputLines(count: 1)
        if isSecure {
            // http://stackoverflow.com/a/30878869/2611971
            let entry: UnsafeMutablePointer<Int8> = getpass("")
            let pointer: UnsafePointer<CChar> = .init(entry)
            guard var pass = String(validatingUTF8: pointer) else {
                return ""
            }
            if pass.hasSuffix("\n") {
                pass = String(pass.dropLast())
            }
            return pass
        } else {
            return readLine(strippingNewline: true) ?? ""
        }
    }

    /// See OutputConsole.output
    public func output(_ string: String, style: ConsoleStyle, newLine: Bool) {
        var lines = 0
        let count = string.count
        if count > size.width && count > 0 && size.width > 0 {
            lines += (count / size.width) + 1
        }
        if newLine {
            lines += 1
        }
        didOutputLines(count: lines)

        let terminator = newLine ? "\n" : ""

        let output: String
        if applyStyle {
            output = string.terminalStylize(style)
        } else {
            output = string
        }

        Swift.print(output, terminator: terminator)
        fflush(stdout)
    }

    /// See ErrorConsole.error
    public func report(error: String, newLine: Bool) {
        let output = newLine ? error + "\n" : error
        let data = output.data(using: .utf8) ?? Data()
        FileHandle.standardError.write(data)
    }

    /// See: BaseConsole.size
    public var size: (width: Int, height: Int) {
        var w = winsize()
        _ = ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &w);
        return (Int(w.ws_col), Int(w.ws_row))
    }
}

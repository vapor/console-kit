import Strand
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public class Loader {
    var strand: Strand?
    weak var console: Terminal?

    public init(console: Terminal, loop: () -> ()) {
        self.console = console
        do {
            strand = try Strand {
                loop()
            }
        } catch {
            strand = nil
        }
    }

    func stop() {
        console?.clearLine()
        do {
            try strand?.cancel()
        } catch {
            strand = nil
        }
    }

    deinit {
        stop()
    }
}
public class Terminal: Console {
    /**
        Creates an instance of Terminal.
    */
    public init() { }

    /**
        Prints styled output to the terminal.
    */
    public func output(_ string: String, style: ConsoleStyle, newLine: Bool) {
        let terminator = newLine ? "\n" : ""

        let output: String
        if let color = style.color {
            output = string.colorize(color.foreground)
        } else {
            output = string
        }

        Swift.print(output, terminator: terminator)
    }

    public func loader(width: Int = 50) -> Loader {
        return Loader(console: self) { [weak self] in
            var current: Int = -1
            var inc: Int = 1
            let cycles = width

            while true {
                if current >= 0 {
                    self?.clearLine()
                } else {
                    current = 0
                }

                var string: String = "["

                let pos = (width / cycles) * current
                for i in 0 ..< width {
                    if i == pos {
                        string += "•"
                    } else {
                        string += " "
                    }
                }

                string += "]"

                string += " Loading..."

                self?.output(string, style: .custom(.cyan))

                current += inc
                if current == cycles || current == 0 {
                    inc *= -1
                }
                usleep(10 * 1000)
            }
        }
    }

    public func clearLine() {
        output("1A".ansi, newLine: false)
        output("2K".ansi, newLine: false)
    }

    public func progress(_ percent: Double, width: Int = 50, failed: Bool = false) {
        if percent != 0 {
            clearLine()
        }

        let current = Int(percent * Double(width))

        var string: String = "["

        for i in 0 ..< width {
            if i <= current {
                string += "="
            } else {
                string += " "
            }
        }

        string += "]"

        if failed {
            string += " ❌"
        } else{
            let progress = Int(percent * 100.0)
            if progress < 100 {
                string += " \(progress)%"
            } else {
                string += " ✅"
            }
        }

        output(string, style: .custom(.magenta), newLine: true)
    }

    /**
        Reads a line of input from the terminal.
    */
    public func input() -> String {
        return readLine(strippingNewline: true) ?? ""
    }
}

extension UInt8 {
    /**
        Formats a terminal code in ANSI.
    */
    private var ansi: String {
        return (self.description + "m").ansi
    }
}

extension String {
    private var ansi: String {
        return "\u{001B}[" + self
    }

    private static var eraseLine: String {
        return "2K".ansi
    }

    /**
        Wraps a string in a color.
    */
    private func colorize(_ color: UInt8) -> String {
        return color.ansi + self + UInt8(0).ansi
    }
}

extension ConsoleColor {
    /**
        Returns the foreground terminal color 
        code for the ConsoleColor.
    */
    private var foreground: UInt8 {
        switch self {
        case .black:
            return 30
        case .red:
            return 31
        case .green:
            return 32
        case .yellow:
            return 33
        case .blue:
            return 34
        case .magenta:
            return 35
        case .cyan:
            return 36
        case .white:
            return 37
        }
    }

    /**
        Returns the background terminal color
        code for the ConsoleColor.
    */
    private var background: UInt8 {
        switch self {
        case .black:
            return 40
        case .red:
            return 41
        case .green:
            return 42
        case .yellow:
            return 43
        case .blue:
            return 44
        case .magenta:
            return 45
        case .cyan:
            return 46
        case .white:
            return 47
        }
    }
}

extension ConsoleStyle {
    /**
        Returns the terminal console color
        for the ConsoleStyle.
    */
    private var color: ConsoleColor? {
        let color: ConsoleColor?

        switch self {
        case .plain:
            color = nil
        case .info:
            color = .cyan
        case .warning:
            color = .yellow
        case .error:
            color = .red
        case .custom(let c):
            color = c
        }

        return color
    }
}

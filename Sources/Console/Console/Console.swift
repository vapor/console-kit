import libc

/**
    Protocol for powering styled Console I/O.
*/
public protocol Console {
    func output(_ string: String, style: ConsoleStyle, newLine: Bool)
    func input() -> String
    func clear(_ clear: ConsoleClear)
    func execute(_ command: String) throws
    func subexecute(_ command: String) throws -> String
    var confirmOverride: Bool? { get }
}

extension Console {
    /**
        Out method with plain default and newline.
    */
    public func output(_ string: String, style: ConsoleStyle = .plain, newLine: Bool = true) {
        output(string, style: style, newLine: newLine)
    }

    public func wait(seconds: Double) {
        let factor = 1000 * 1000
        let microseconds = seconds * Double(factor)
        usleep(useconds_t(microseconds))
    }

    public var confirmOverride: Bool? {
        return nil
    }
}

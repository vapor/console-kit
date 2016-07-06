import libc
import Foundation

/**
    Protocol for powering styled Console I/O.
*/
public protocol Console {
    /**
        Outputs a String in the given style to 
        the console. If newLine is true, the next
        output will appear on a new line.
    */
    func output(_ string: String, style: ConsoleStyle, newLine: Bool)

    /**
        Returns a String of input read from the
        console until a line feed character was found.
     
        The line feed character should not be included.
    */
    func input() -> String

    /**
        Clears previously printed Console outputs
        according to the ConsoleClear type given.
    */
    func clear(_ clear: ConsoleClear)

    /**
        Executes a command using the console's POSIX subsystem.
        The input, output, and error streams will be used
        during the execution.
     
        throws: ConsoleError.execute(Int)
    */
    func execute(_ command: String, input: Stream?, output: Stream?, error: Stream?) throws

    /**
        When set, all `confirm(_ prompt:)` methods
        will return the value. When nil, the confirm
        calls will wait for input from `input()`
    */
    var confirmOverride: Bool? { get }

    /**
        The size of the console window used for centering.
    */
    var size: (width: Int, height: Int) { get }
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

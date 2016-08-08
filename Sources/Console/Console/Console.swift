import libc
import Foundation

/**
    Protocol for powering styled Console I/O.
*/
public protocol ConsoleProtocol {
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
        Executes a task using the supplied 
        FileHandles for IO.
    */
    func execute(_ command: String, input: Int32?, output: Int32?, error: Int32?) throws

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

extension ConsoleProtocol {
    /**
        Executes a command using the console's POSIX subsystem.
        The input, output, and error streams will appear
        as though they are coming from the console program.

        - throws: ConsoleError.execute(Int)
    */
    public func foregroundExecute(_ command: String) throws {
        #if os(Linux)
            let stdin = FileHandle.standardInput()
            let stdout = FileHandle.standardOutput()
            let stderr = FileHandle.standardError()
        #else
            let stdin = FileHandle.standardInput
            let stdout = FileHandle.standardOutput
            let stderr = FileHandle.standardError
        #endif
        
        try execute(
            command,
            input: stdin.fileDescriptor,
            output: stdout.fileDescriptor,
            error: stderr.fileDescriptor
        )
    }

    /**
        Executes a command using the console's POSIX subsystem.
        The input, output, and error streams will be input
        and returned as strings.

        - input: Input argument to method
        - output: The return string from the method
        - error: The string in the error enumeration ConsoleError.subexcute

        - throws: ConsoleError.subexecute(Int, String)
    */
    public func backgroundExecute(_ command: String) throws -> String {
        let input = Pipe()
        let output = Pipe()
        let error = Pipe()

        do {
            try execute(
                command,
                input: input.fileHandleForReading.fileDescriptor,
                output: output.fileHandleForWriting.fileDescriptor,
                error: error.fileHandleForWriting.fileDescriptor
            )
        } catch ConsoleError.execute(let result) {
            close(error.fileHandleForWriting.fileDescriptor)
            let error = String(data: error.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "Unknown"
            throw ConsoleError.subexecute(result, error)
        }

        close(output.fileHandleForWriting.fileDescriptor)
        let data = output.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}

extension ConsoleProtocol {
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

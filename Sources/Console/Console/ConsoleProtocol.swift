import libc
import Foundation
import Core

public enum ConsoleStream {
    /// Returns a String of input read from the
    /// console until a line feed character was found.
    ///
    /// The line feed character should not be included.
    ///
    /// If secure is true, the input should not be
    /// shown while it is entered.
    case input(secure: Bool)
    /// Outputs a String in the given style to
    /// the console. If newLine is true, the next
    /// output will appear on a new line.
    case output(String, ConsoleStyle, newLine: Bool)
    /// Outputs an error
    case error(String, newLine: Bool)
    /// Clears previously printed Console outputs
    /// according to the ConsoleClear type given.
    case clear(ConsoleClear)
}

public enum ExecuteStream {
    case fileHandle(FileHandle)
    case pipe(Pipe)
}

extension ExecuteStream {
    internal var either: Any {
        switch self {
        case .fileHandle(let handle):
            return handle
        case .pipe(let pipe):
            return pipe
        }
    }
}

extension ConsoleProtocol {
    public func input(secure: Bool = false) -> String {
        didOutputLines(count: 1)
        return stream(.input(secure: secure)) ?? ""
    }
}

/// Protocol for powering styled Console I/O.
public protocol ConsoleProtocol: Extendable {
    /// Handles all input/output/error/clear commands
    /// supported by the `ConsoleStream` enum.
    @discardableResult
    func stream(_ stream: ConsoleStream) -> String?

    /// Executes a task using the supplied
    /// FileHandles for IO.
    func execute(
        program: String,
        arguments: [String],
        input: ExecuteStream?,
        output: ExecuteStream?,
        error: ExecuteStream?
    ) throws

    /// The size of the console window used for
    /// calculating lines printed and centering tet.
    var size: (width: Int, height: Int) { get }
}

extension ConsoleProtocol {
    public func foregroundExecute(program: String, arguments: [String]) throws {
        let stdin = FileHandle.standardInput
        let stdout = FileHandle.standardOutput
        let stderr = FileHandle.standardError
        
        try execute(
            program: program,
            arguments: arguments,
            input: .fileHandle(stdin),
            output: .fileHandle(stdout),
            error: .fileHandle(stderr)
        )
    }
    
    public func foregroundExecute(commands: [String]) throws {
        try foregroundExecute(program: commands[0], arguments: commands.dropFirst(1).array)
    }
    
    public func foregroundExecute(commands: String...) throws {
        try foregroundExecute(commands: commands)
    }

    public func backgroundExecute(program: String, arguments: [String]) throws -> Bytes {
        let input = Pipe()
        let output = Pipe()
        let error = Pipe()
        
        do {
            try execute(
                program: program,
                arguments: arguments,
                input: .pipe(input),
                output: .pipe(output),
                error: .pipe(error)
            )
        } catch ConsoleError.execute(let result) {
            let error = error.read()
            let output = output.read()

            throw ConsoleError.backgroundExecute(
                code: result,
                error: error.makeString(),
                output: output.makeString()
            )
        }

        let bytes = output
            .fileHandleForReading
            .readDataToEndOfFile()
            .makeBytes()
        return bytes
    }
    
    public func backgroundExecute<Type: BytesInitializable>(program: String, arguments: [String]) throws -> Type {
        let bytes = try backgroundExecute(program: program, arguments: arguments) as Bytes
        return try Type(bytes: bytes)
    }
    
    public func backgroundExecute<Type: BytesInitializable>(commands: [String]) throws -> Type {
        return try backgroundExecute(program: commands[0], arguments: commands.dropFirst(1).array)
    }
    
    public func backgroundExecute<Type: BytesInitializable>(commands: String...) throws -> Type {
        return try backgroundExecute(commands: commands)
    }

    public func registerKillListener(_ listener: @escaping (Int32) -> Void) {

    }
}

extension ConsoleProtocol {
    /// Out method with plain default and newline.
    public func output(_ string: String, style: ConsoleStyle = .plain, newLine: Bool = true) {
        var lines = 0
        let count = string.characters.count
        if count > size.width && count > 0 && size.width > 0 {
            lines += (count / size.width) + 1
        }
        if newLine {
            lines += 1
        }
        didOutputLines(count: lines)
        stream(.output(string, style, newLine: newLine))
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

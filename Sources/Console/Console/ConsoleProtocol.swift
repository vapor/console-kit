import libc
import Foundation
import Core


/// Protocol for powering styled Console I/O.
public protocol ConsoleProtocol: Extendable {
    /// Outputs a String in the given style to
    /// the console. If newLine is true, the next
    /// output will appear on a new line.
    func output(_ string: String, style: ConsoleStyle, newLine: Bool)
    
    /// Returns a String of input read from the
    /// console until a line feed character was found.
    ///
    /// The line feed character should not be included.
    func input() -> String
    
    /// Returns a string of input read from the console
    /// until a line feed character was found,
    /// hides entry for security
    func secureInput() -> String
    
    /// Clears previously printed Console outputs
    /// according to the ConsoleClear type given.
    func clear(_ clear: ConsoleClear)
    
    /// Executes a task using the supplied
    /// FileHandles for IO.
    func execute(program: String, arguments: [String], input: Int32?, output: Int32?, error: Int32?) throws
    
    /// When set, all `confirm(_ prompt:)` methods
    /// will return the value. When nil, the confirm
    /// calls will wait for input from `input()`
    var confirmOverride: Bool? { get }
    
    /// The size of the console window used for centering.
    var size: (width: Int, height: Int) { get }
    
    /// Executes a command using the console's POSIX subsystem.
    /// The input, output, and error streams will appear
    /// as though they are coming from the console program.
    ///
    /// - parameter program: Program to be executed
    /// - parameter arguments: Input arguments to the program
    ///
    /// - throws: ConsoleError.execute(Int)
    func foregroundExecute(program: String, arguments: [String]) throws
    
    /// Executes a command using the console's POSIX subsystem.
    /// The input, output, and error streams will be input
    /// and returned as strings.
    ///
    /// - parameter program: Program to be executed
    /// - parameter arguments: Input arguments to the program
    
    /// - throws: ConsoleError.subexecute(Int, String)
    ///
    /// - returns: The return string from the method
    func backgroundExecute(program: String, arguments: [String]) throws -> String
    
    /// Upon a console instance being killed for example w/ ctrl+c
    /// a console should forward the message to kill listeners
    func registerKillListener(_ listener: @escaping (Int32) -> Void)
}

extension ConsoleProtocol {
    public var extend: [String : Any] {
        get {
            error("\(Self.self) does not conform to Extendable.")
            return [:]
        }
        set {
            error("\(Self.self) does not conform to Extendable.")
        }
    }
}

extension ConsoleProtocol {
    public func foregroundExecute(program: String, arguments: [String]) throws {
        let stdin = FileHandle.standardInput
        let stdout = FileHandle.standardOutput
        let stderr = FileHandle.standardError
        
        try execute(
            program: program,
            arguments: arguments,
            input: stdin.fileDescriptor,
            output: stdout.fileDescriptor,
            error: stderr.fileDescriptor
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
                input: input.fileHandleForReading.fileDescriptor,
                output: output.fileHandleForWriting.fileDescriptor,
                error: error.fileHandleForWriting.fileDescriptor
            )
        } catch ConsoleError.execute(let result) {
            close(error.fileHandleForWriting.fileDescriptor)
            close(output.fileHandleForWriting.fileDescriptor)
            let error = error.fileHandleForReading.readDataToEndOfFile().makeBytes()
            let output = output.fileHandleForReading.readDataToEndOfFile().makeBytes()
            
            throw ConsoleError.backgroundExecute(code: result, error: error.makeString(), output: output.makeString())
        }
        
        close(output.fileHandleForWriting.fileDescriptor)
        return output.fileHandleForReading.readDataToEndOfFile().makeBytes()
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

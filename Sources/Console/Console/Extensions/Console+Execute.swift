import Bits
import Foundation

// MARK: Foreground

extension ExecuteConsole {
    /// Execute the program using standard IO.
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

    /// Execute a program using an array of commands.
    public func foregroundExecute(commands: [String]) throws {
        try foregroundExecute(program: commands[0], arguments: Array(commands.dropFirst(1)))
    }

    /// Execute a program using a variadic array.
    public func foregroundExecute(commands: String...) throws {
        try foregroundExecute(commands: commands)
    }
}

// MARK: Background

/// Result from a raw background execution.
public struct BackgroundExecuteResult {
    /// Error that was thrown while executing, if there was one.
    public var error: Error?
    /// Data from `stdout` stream.
    public var standardOutput: Data
    /// Data from `stderr` stream.
    public var standardError: Data
}

extension ExecuteConsole {
    /// Execute the program in the background, returning the result of the run as bytes.
    public func backgroundExecuteRaw(program: String, arguments: [String], input: ExecuteStream? = nil) throws -> BackgroundExecuteResult {
        let stdin = input ?? .pipe(Pipe())
        let stdout = Pipe()
        let stderr = Pipe()

        var e: Error?

        do {
            try execute(
                program: program,
                arguments: arguments,
                input: stdin,
                output: .pipe(stdout),
                error: .pipe(stderr)
            )
        } catch {
            e = error
        }

        return BackgroundExecuteResult(
            error: e,
            standardOutput: stdout.fileHandleForReading.readDataToEndOfFile(),
            standardError: stderr.fileHandleForReading.readDataToEndOfFile()
        )
    }

    /// Execute the program in the background, intiailizing a type with the returned bytes.
    public func backgroundExecute(program: String, arguments: [String], input: String? = nil) throws -> String {
        let stdin = Pipe()
        if let input = input {
            stdin.fileHandleForWriting.write(Data(input.utf8))
        }
        let result = try backgroundExecuteRaw(program: program, arguments: arguments, input: .pipe(stdin))

        if let error = result.error {
            throw error
        }

        guard let string = String(data: result.standardOutput, encoding: .utf8) else {
            throw ConsoleError(identifier: "executeString", reason: "Could not convert Data to String", source: .capture())
        }

        return string
    }

    /// Execute the program in the background, intiailizing a type with the returned bytes.
    public func backgroundExecute(commands: [String]) throws -> String {
        return try backgroundExecute(program: commands[0], arguments: Array(commands.dropFirst(1)))
    }

    /// Execute the program in the background, intiailizing a type with the returned bytes.
    public func backgroundExecute(commands: String...) throws -> String {
        return try backgroundExecute(commands: commands)
    }
}

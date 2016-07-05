import libc
import Foundation

public class Terminal: Console {
    public enum Error: ErrorProtocol {
        case cancelled
        case execute(Int)
    }

    public let arguments: [String]
    
    /**
        Creates an instance of Terminal.
    */
    public init(arguments: [String]) {
        self.arguments = arguments
    }

    /**
        Prints styled output to the terminal.
    */
    public func output(_ string: String, style: ConsoleStyle, newLine: Bool) {
        let terminator = newLine ? "\n" : ""

        let output: String
        if let color = style.terminalColor {
            #if !Xcode
                output = string.terminalColorize(color)
            #else
                output = string
            #endif
        } else {
            output = string
        }

        Swift.print(output, terminator: terminator)
    }

    /**
        Clears text from the terminal window.
    */
    public func clear(_ clear: ConsoleClear) {
        #if !Xcode
        switch clear {
        case .line:
            command(.cursorUp)
            command(.eraseLine)
        case .screen:
            command(.eraseScreen)
        }
        #endif
    }

    /**
        Reads a line of input from the terminal.
    */
    public func input() -> String {
        //let string = String(data: FileHandle.standardInput().readData(ofLength: 2), encoding: .utf8) ?? "Unknown"
        //Swift.print(string)
        return readLine(strippingNewline: true) ?? ""
    }

    public func execute(_ command: String) throws {
        let task = Task()

        task.arguments = ["-c", command]
        task.launchPath = "/bin/sh"

        task.standardInput = FileHandle.standardInput()

        task.launch()
        task.waitUntilExit()

        let result = task.terminationStatus

        if result == 2 {
            throw Error.cancelled
        } else if result != 0 {
            throw ConsoleError.execute(Int(result))
        }
    }


    public func subexecute(_ command: String) throws -> String {
        let task = Task()

        let standardOutput = Pipe()
        let standardError = Pipe()

        task.arguments = ["-c", command]
        task.launchPath = "/bin/sh"
        task.standardOutput = standardOutput
        task.standardError = standardError

        task.launch()
        task.waitUntilExit()

        let result = task.terminationStatus

        if result == 2 {
            throw Error.cancelled
        } else if result != 0 {
            let error = String(data: standardError.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "Unknown"
            throw ConsoleError.subexecute(Int(result), error)
        }

        return String(data: standardOutput.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    }

    public var confirmOverride: Bool? {
        if arguments.contains("-y") {
            return true
        } else if arguments.contains("-n") {
            return false
        }

        return nil
    }

    /**
        Runs an ansi coded command.
    */
    private func command(_ command: Command) {
        output(command.ansi, newLine: false)
    }
}

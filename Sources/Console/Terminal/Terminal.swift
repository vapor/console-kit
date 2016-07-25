import libc
import Foundation

public class Terminal: ConsoleProtocol {
    public enum Error: Swift.Error {
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
        return readLine(strippingNewline: true) ?? ""
    }

    public func execute(_ command: String) throws {
        let input = FileHandle.standardInput
        let output = FileHandle.standardOutput
        let error = FileHandle.standardError

        try execute(command, input: input, output: output, error: error)
    }

    public func subexecute(_ command: String, input: String) throws -> String {
        let output = Pipe()
        let input = Pipe()
        let error = Pipe()

        do {
            try execute(command, input: input, output: output, error: error)
        } catch ConsoleError.execute(let result) {
            #if os(Linux)
                let error = String(data: error.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding) ?? "Unknown"
            #else
                let error = String(data: error.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "Unknown"
            #endif
            throw ConsoleError.subexecute(result, error)
        }

        #if os(Linux)
            return String(data: output.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding) ?? ""
        #else
            return String(data: output.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        #endif
    }

    private var pids: [pid_t] = []

    private func execute(_ command: String, input: AnyObject?, output: AnyObject?, error: AnyObject?) throws {
        let task = Task()

        task.arguments = ["-c", command]
        task.launchPath = "/bin/sh"

        task.standardInput = input
        task.standardOutput = output
        task.standardError = error

        task.launch()

        pids.append(task.processIdentifier)

        task.waitUntilExit()

        for (i, pid) in pids.enumerated() {
            if pid == task.processIdentifier {
                pids.remove(at: i)
                break
            }
        }

        let result = task.terminationStatus

        if result == 2 {
            throw ConsoleError.cancelled
        } else if result != 0 {
            throw ConsoleError.execute(Int(result))
        }
    }

    public var confirmOverride: Bool? {
        if arguments.contains("-y") {
            return true
        } else if arguments.contains("-n") {
            return false
        }

        return nil
    }

    public var size: (width: Int, height: Int) {
        // Get the columns and lines from tput
        let tput = "/usr/bin/tput"

        do {
            // FIXME: tput doesn't work with NSTask
            let cols = try subexecute("\(tput) cols").trim()
            let lines = try subexecute("\(tput) lines").trim()

            return (Int(cols) ?? 0, Int(lines) ?? 0)
        } catch {
            return (0, 0)
        }
    }

    /**
        Runs an ansi coded command.
    */
    private func command(_ command: Command) {
        output(command.ansi, newLine: false)
    }

    public func killTasks() {
        for pid in pids {
            kill(pid, SIGINT)
        }
    }

    deinit {
        killTasks()
    }
}

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
        return readLine(strippingNewline: true) ?? ""
    }

    public func execute(_ command: String, input: IOStream?, output: IOStream?, error: IOStream?) throws {
        let task = Task()

        task.arguments = ["-c", command]
        task.launchPath = "/bin/sh"

        task.standardInput = input
        task.standardOutput = output
        task.standardError = error

        task.launch()

        task.waitUntilExit()

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
            let cols = try executeInBackground("\(tput) cols").trim()
            let lines = try executeInBackground("\(tput) lines").trim()

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
}

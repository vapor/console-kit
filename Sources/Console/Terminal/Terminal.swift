import libc

public class Terminal: Console {
    public enum Error: ErrorProtocol {
        case cancelled
        case execute(Int)
    }
    
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
        if let color = style.terminalColor {
            output = string.terminalColorize(color)
        } else {
            output = string
        }

        Swift.print(output, terminator: terminator)
    }

    /**
        Clears text from the terminal window.
    */
    public func clear(_ clear: ConsoleClear) {
        switch clear {
        case .line:
            command(.cursorUp)
            command(.eraseLine)
        case .screen:
            command(.eraseScreen)
        }
    }

    /**
        Reads a line of input from the terminal.
    */
    public func input() -> String {
        return readLine(strippingNewline: true) ?? ""
    }

    public func execute(_ command: String) throws {
        let result = libc.system(command)

        if result == 2 {
            throw Error.cancelled
        } else if result != 0 {
            throw ConsoleError.execute(Int(result) / 256)
        }

    }

    public func subexecute(_ command: String) throws -> String {
        // Run the command
        let fp = popen("\(command) 2>&1", "r")

        var output = ""

        if let fp = fp {
            // Get the output of the command
            let pathSize = 1024

            let path: UnsafeMutablePointer<Int8> = UnsafeMutablePointer(allocatingCapacity: pathSize)
            defer {
                path.deallocateCapacity(pathSize)
            }

            while fgets(path, Int32(pathSize - 1), fp) != nil {
                output += String(cString: path)
            }
        } else {
            throw ConsoleError.execute(1)
        }


        let exit = pclose(fp) / 256

        if exit == 2 {
            throw Error.cancelled
        } else if exit != 0 {
            throw ConsoleError.execute(Int(exit))
        }

        return output
    }

    /**
        Runs an ansi coded command.
    */
    private func command(_ command: Command) {
        output(command.ansi, newLine: false)
    }
}

import libc
import Foundation

/**
    Protocol for powering styled Console I/O.
*/
public protocol Console {
    func output(_ string: String, style: ConsoleStyle, newLine: Bool)
    func input() -> String
    func clear(_ clear: ConsoleClear)
    func execute(_ command: String, input: AnyObject?, output: AnyObject?, error: AnyObject?) throws
    var confirmOverride: Bool? { get }
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

extension Console {
    public func executeInBackground(_ command: String, input: AnyObject? = nil) throws -> String {
        let output = Pipe()
        let error = Pipe()

        do {
            try execute(command, input: input, output: output, error: error)
        } catch ConsoleError.execute(let result) {
            let error = String(data: error.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "Unknown"
            throw ConsoleError.backgroundExecute(result, error)
        }

        return String(data: output.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    }

    public func executeInForeground(_ command: String) throws {
        let input = FileHandle.standardInput()
        let output = FileHandle.standardOutput()
        let error = FileHandle.standardError()

        try execute(command, input: input, output: output, error: error)
    }
}

extension Console {
    public func center(_ string: String, paddingCharacter: Character = " ") -> String {
        // Split the string into lines
        let lines = string.characters.split(separator: Character("\n")).map(String.init)
        return center(lines).joined(separator: "\n")
    }
    public func center(_ lines: [String], paddingCharacter: Character = " ") -> [String] {
        var lines = lines

        // Make sure there's more than one line
        guard lines.count > 0 else {
            return []
        }

        // Find the longest line
        var longestLine = 0
        for line in lines {
            if line.characters.count > longestLine {
                longestLine = line.characters.count
            }
        }

        // Calculate the padding and make sure it's greater than or equal to 0
        let padding = max(0, (size.width - longestLine) / 2)

        // Apply the padding to each line
        for i in 0..<lines.count {
            for _ in 0..<padding {
                lines[i].insert(paddingCharacter, at: lines[i].startIndex)
            }
        }

        return lines
    }
}

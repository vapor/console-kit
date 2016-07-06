import Foundation

extension Console {
    public func executeInBackground(_ command: String, input: Stream? = nil) throws -> String {
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

import Foundation

extension Console {
    public func executeInBackground(_ command: String, input: IOStream? = nil) throws -> String {
        let output = Pipe()
        let error = Pipe()

        do {
            try execute(command, input: input, output: output, error: error)
        } catch ConsoleError.execute(let result) {
            #if os(Linux)
                let error = String(data: error.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding) ?? "Unknown"
            #else
                let error = String(data: error.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "Unknown"
            #endif
            throw ConsoleError.backgroundExecute(result, error)
        }

        #if os(Linux)
        return String(data: output.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
        #else
        return String(data: output.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        #endif
    }

    public func executeInForeground(_ command: String) throws {
        let input = FileHandle.standardInput()
        let output = FileHandle.standardOutput()
        let error = FileHandle.standardError()

        try execute(command, input: input, output: output, error: error)
    }
}

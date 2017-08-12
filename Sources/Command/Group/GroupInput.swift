import Console

public struct GroupInput {
    public let executable: String
    public let options: [String: String]

    public init(executable: String, options: [String: String]) {
        self.executable = executable
        self.options = options
    }
}

extension GroupInput {
    public func assertOption(_ name: String) throws -> String {
        guard let option = options[name] else {
            throw ConsoleError(identifier: "missingOption", reason: "Option `\(name)` is requried and was not supplied.")
        }

        return option
    }
}

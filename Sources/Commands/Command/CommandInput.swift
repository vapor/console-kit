import Consoles

public struct CommandInput {
    public let executable: String
    public let arguments: [String: String]
    public let options: [String: String]
}

extension CommandInput {
    public func argument(_ name: String) throws -> String {
        guard let arg = arguments[name] else {
            throw ConsoleError(reason: "No argument named `\(name)` exists in the command signature.")
        }

        return arg
    }

    public func assertOption(_ name: String) throws -> String {
        guard let option = options[name] else {
            throw ConsoleError(reason: "Option `\(name)` is required and was not supplied.")
        }

        return option
    }
}

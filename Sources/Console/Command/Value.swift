public struct Value: Argument {
    public var name: String
    public var help: [String]

    public init(name: String, help: [String] = []) {
        self.name = name
        self.help = help
    }
}

extension Command {
    public func value(_ name: String, from arguments: [String]) throws -> String {
        for (i, value) in signature.values.enumerated() {
            if value.name == name {
                return arguments[i]
            }
        }

        throw ConsoleError.argumentNotFound
    }
}


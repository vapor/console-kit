/// Raw input for commands. Use this to parse options and arguments for the command context.
public struct CommandInput: Sendable {
    /// The `CommandInput`'s raw arguments. This array will be mutated as arguments and options
    /// are parsed from the `CommandInput`.
    public var arguments: [String]

    /// The current executable path.
    public var executablePath: [String]

    public var executable: String {
        return self.executablePath.joined(separator: " ")
    }

    /// Create a new `CommandInput`.
    public init(arguments: [String]) {
        precondition(arguments.count >= 1, "At least one argument (the executable path) is required")
        var arguments = arguments
        executablePath = [arguments.popFirst()!]
        self.arguments = arguments
    }

    mutating func nextArgument() -> String? {
        guard let index = self.arguments.firstIndex(where: { argument in
            return !argument.hasPrefix("-")
        }) else {
            return nil
        }
        return self.arguments.remove(at: index)
    }

    mutating func nextFlag(name: String, short: Character?) -> Bool {
        guard let flagIndex = self.nextFlagIndex(name: name, short: short) else {
            return false
        }
        self.arguments.remove(at: flagIndex)
        return true
    }

    mutating func nextOption(name: String, short: Character?) -> (value: String?, passedIn: Bool) {
        guard let flagIndex = self.nextFlagIndex(name: name, short: short) else {
            return (nil, false)
        }
        // ensure there is a value after this index
        let valueIndex = self.arguments.index(after: flagIndex)
        guard valueIndex < self.arguments.endIndex else {
            return (nil, true)
        }

        let value = self.arguments[valueIndex]
        switch value.first {
        case "-": return (nil, true)
        case "\\":
            self.arguments.removeSubrange(flagIndex...valueIndex)
            return (String(value.dropFirst()), true)
        default:
            self.arguments.removeSubrange(flagIndex...valueIndex)
            return (value, true)
        }
    }

    private func nextFlagIndex(name: String, short: Character?) -> Array<String>.Index? {
        if let index = self.arguments.firstIndex(where: { argument in
            return argument == "--\(name)"
        }) {
            return index
        } else if let short = short, let index = self.arguments.firstIndex(where: { argument in
            return argument == "-\(short)"
        }) {
            return index
        } else {
            return nil
        }
    }
}

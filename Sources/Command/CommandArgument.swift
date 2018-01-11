/// A required argument for a command.
///
///     exec command <arg>
///
public struct CommandArgument {
    /// The argument's unique name.
    public let name: String

    /// The arguments's help text when `--help` is passed.
    public let help: [String]

    /// Creates a new command argument
    /// Create via static methods.
    internal init(name: String, help: [String]) {
        self.name = name
        self.help = help
    }
}

/// MARK: Create

extension CommandArgument {
    public static func argument(name: String, help: [String] = []) -> CommandArgument {
        return .init(name: name, help: help)
    }
}

/// A supported option for a command.
///
///     exec command [--opt]
///
public struct CommandOption {
    /// The option's unique name.
    public let name: String

    /// The option's short flag
    public let short: Character?

    /// The option's type.
    /// See `CommandOptionType`
    public let type: CommandOptionType

    /// The option's help text when `--help` is passed.
    public let help: [String]

    /// Creates a new `CommandOption`.
    internal init(
        name: String,
        short: Character?,
        type: CommandOptionType,
        help: [String]
    ) {
        self.name = name
        self.type = type
        self.short = short
        self.help = help
    }
}

// MARK: Type

/// Supported `CommandOption` types.
public enum CommandOptionType {
    /// Normal option. Requires a value if supplied and there is no default.
    ///
    ///     --branch beta
    ///
    case value(default: String?)
    /// Flag option. Does not support a value. If supplied, the value is true.
    ///
    ///     --xcode
    ///
    case flag
}

/// MARK: Create

extension CommandOption {
    /// Creates a `.value` `CommandOption`.
    /// See `CommandOptionType`.
    public static func value(name: String, short: Character? = nil, default: String? = nil, help: [String] = []) -> CommandOption {
        return .init(name: name, short: short, type: .value(default: `default`), help: help)
    }

    /// Creates a `.flag` `CommandOption`.
    /// See `CommandOptionType`.
    public static func flag(name: String, short: Character? = nil, help: [String] = []) -> CommandOption {
        return .init(name: name, short: short, type: .flag, help: help)
    }
}

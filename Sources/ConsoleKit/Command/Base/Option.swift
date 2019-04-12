/// A type-erased `Option`.
public protocol AnyOption {
    /// The option's unique name.
    var name: String { get }
    
    /// The option's help text when `--help` is passed in.
    var help: String? { get }
    
    /// The option's short flag.
    var short: Character? { get }
    
    /// The type of command option that the instance represents.
    var optionType: OptionType { get }
    
    /// The type that the option value gets decoded to.
    var type: LosslessStringConvertible.Type { get }
}

/// A supported option for a command.
///
///     exec command [--opt -o]
///
public struct Option<Value>: AnyOption where Value: LosslessStringConvertible {
    /// The option's unique name.
    public let name: String
    
    /// The option's short flag.
    public let help: String?
    
    /// The option's help text when `--help` is passed in.
    public let short: Character?
    
    /// The type of command option that the instance represents.
    ///
    /// The option could be a flag:
    ///
    ///     exec command -f
    ///
    /// Of a value:
    ///
    ///     exec command -v foo
    public let optionType: OptionType
    
    /// The type that the option value gets decoded to.
    ///
    /// Required by `AnyOption`.
    public var type: LosslessStringConvertible.Type {
        return Value.self
    }
    
    /// Creates a new `Option` with the `optionType` set to `.flag`.
    ///
    ///     let verbose = Option<Bool>(name: "verbose", short: "v", help: "Output debug logs")
    ///
    /// - Parameters:
    ///   - name: The option's unique name. Use this to get the option value from the `CommandContext`.
    ///   - short: The short-hand for the flag that can be passed in to the command call.
    ///   - help: The option's help text when `--help` is passed in.
    public init(
        name: String,
        short: Character? = nil,
        help: String? = nil
    ) {
        self.name = name
        self.short = short
        self.help = help
        self.optionType = .flag
    }
    
    /// Creates a new `Option` with the `optionType` set to `.value`.
    ///
    ///     let verbose = Option<Bool>(name: "verbose", short: "v", help: "Output debug logs")
    ///
    /// - Parameters:
    ///   - name: The option's unique name. Use this to get the option value from the `CommandContext`.
    ///   - short: The short-hand for the flag that can be passed in to the command call.
    ///   - default: The option's default value if none is passed in with the option when the command is run.
    ///   - help: The option's help text when `--help` is passed in.
    public init(
        name: String,
        short: Character? = nil,
        default: Value?,
        help: String? = nil
    ) {
        self.name = name
        self.short = short
        self.help = help
        self.optionType = .value(default: `default`?.description)
    }
}

public enum OptionType {
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

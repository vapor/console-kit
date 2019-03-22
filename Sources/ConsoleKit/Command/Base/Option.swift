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
public struct Option<T>: AnyOption where T: LosslessStringConvertible {
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
        return T.self
    }
    
    /// Creates a new `Option`
    ///
    ///     let verbose = Option<Bool>(name: "verbose", short: "v", help: "Output debug logs")
    ///
    /// - Parameters:
    ///   - name: The option's unique name. Use this to get the option value from the `CommandContext`.
    ///   - short: The short-hand for the flag that can be passed in to the command call.
    ///   - help: The option's help text when `--help` is passed in.
    ///   - type: The type of command option. This can be a `flag` or `value`.
    public init(
        name: String,
        short: Character? = nil,
        type: OptionType = .flag,
        help: String? = nil
    ) {
        self.name = name
        self.short = short
        self.help = help
        self.optionType = type
    }
    
    /// Creates an `Option` instance with the `optionType` as `.value`
    ///
    ///     Option<Int>.value(name: "result", short: "r", help: "The number of results to fetch", default: 100)
    ///
    /// - Parameters:
    ///   - name: The option's unique name. Use this to get the option value from the `CommandContext`.
    ///   - short: The short-hand for the flag that can be passed in to the command call.
    ///   - help: The option's help text when `--help` is passed in.
    ///   - default: The default value for the option. Defaults to `nil`.
    ///
    /// - Returns: A `.value` type `Option` instance created with the values passed in.
    public static func value(
        name: String,
        short: Character? = nil,
        default: T? = nil,
        help: String? = nil
    ) -> Option<T> {
        return Option<T>(name: name, short: short, type: .value(default: `default`?.description), help: help)
    }
    
    /// Creates an `Option` instance with the `optionType` as `.flat`
    ///
    ///     Option<Bool>.value(name: "verbose", short: "v", help: "Output debug logs")
    ///
    /// - Parameters:
    ///   - name: The option's unique name. Use this to get the option value from the `CommandContext`.
    ///   - short: The short-hand for the flag that can be passed in to the command call.
    ///   - help: The option's help text when `--help` is passed in.
    ///
    /// - Returns: A `.flag` type `Option` instance created with the values passed in.
    public static func flag(name: String, short: Character? = nil, help: String? = nil) -> Option<T> {
        return Option<T>(name: name, short: short, type: .flag, help: help)
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

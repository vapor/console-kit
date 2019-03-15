/// A supported option for a command.
///
///     exec command [--opt -o]
///
public struct Option<T> where T: LosslessStringConvertible {
    private let nameInit: () -> String
    private let helpInit: () -> String?
    private let shortInit: () -> Character?
    
    /// Creates a new `Option`
    ///
    ///     let verbose = Option<Bool>(name: "verbose", short: "v", help: "Output debug logs")
    ///
    /// - Parameters:
    ///   - name: The option's unique name. Use this to get the option value from the `CommandContext`.
    ///   - short: The short-hand for the flag that can be passed in to the command call.
    ///   - help: The option's help text when `--help` is passed in.
    public init(
        name: @escaping @autoclosure () -> String,
        short: @escaping @autoclosure () -> Character? = nil,
        help: @escaping @autoclosure () -> String? = nil
    ) {
        self.nameInit = name
        self.shortInit = short
        self.helpInit = help
    }
    
    /// The option's unique name.
    public var name: String {
        return self.nameInit()
    }
    
    /// The option's short flag
    public var short: Character? {
        return self.shortInit()
    }
    
    /// The option's help text when `--help` is passed in.
    public var help: String? {
        return self.helpInit()
    }
}


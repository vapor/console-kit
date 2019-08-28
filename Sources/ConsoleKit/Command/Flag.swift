/// A supported option for a command.
///
///     exec command [--opt -o]
///
@propertyWrapper
public final class Flag: AnyFlag {
    /// The flag's identifying name.
    public let name: String
    
    /// The option's short flag.
    public let help: String

    /// The option's help text when `--help` is passed in.
    public let short: Character?

    public var projectedValue: Flag {
        return self
    }

    public var wrappedValue: Bool {
        guard let value = self.value else {
            fatalError("Flag \(self.name) was not initialized")
        }
        return value
    }

    var value: Bool?

    /// Creates a new `Option` with the `optionType` set to `.value`.
    ///
    ///     @Option(short: "v", help: "Output debug logs")
    ///     var verbose: Bool?
    ///
    /// - Parameters:
    ///   - short: The short-hand for the flag that can be passed in to the command call.
    ///   - help: The option's help text when `--help` is passed in.
    public init(
        name: String,
        short: Character? = nil,
        help: String = ""
    ) {
        self.name = name
        self.short = short
        self.help = help
    }

    func load(from input: inout CommandInput) throws {
        self.value = input.nextFlag(name: self.name, short: self.short)
    }
}

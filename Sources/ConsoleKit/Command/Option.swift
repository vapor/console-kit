/// A supported option for a command.
///
///     exec command [--opt -o]
///
@propertyWrapper
public final class Option<Value>: AnyOption
    where Value: LosslessStringConvertible
{
    /// The option's identifying name.
    public let name: String
    
    /// The option's short flag.
    public let help: String
    
    /// The option's help text when `--help` is passed in.
    public let short: Character?


    public var wrappedValue: Value? {
        guard let value = self.value else {
            fatalError("Option \(self.name) was not initialized")
        }
        return value
    }

    var value: Value??
    
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
        if let option = input.nextOption(name: self.name, short: self.short) {
            guard let value = Value(option) else {
                throw CommandError(identifier: "option", reason: "Could not convert option for \(self.name) to \(Value.self)")
            }
            self.value = value
        } else {
            self.value = .some(.none)
        }
    }
}

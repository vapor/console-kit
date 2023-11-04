import NIOConcurrencyHelpers

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

    public var initialized: Bool {
        switch self.value.withLockedValue({ $0 }) {
        case .initialized: return true
        case .uninitialized: return false
        }
    }

    public var projectedValue: Flag {
        return self
    }

    public var wrappedValue: Bool {
        switch self.value.withLockedValue({ $0 }) {
        case let .initialized(value): return value
        case .uninitialized: fatalError("Flag \(self.name) was not initialized")
        }
    }

    let value: NIOLockedValueBox<InputValue<Bool>>

    /// Creates a new `Option` with the `optionType` set to `.value`.
    ///
    ///     @Option(name: "verbose", short: "v", help: "Output debug logs")
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
        self.value = .init(.uninitialized)
    }

    func load(from input: inout CommandInput) throws {
        self.value.withLockedValue { $0 = .initialized(input.nextFlag(name: self.name, short: self.short)) }
    }
}

import NIOConcurrencyHelpers

/// A supported option for a command.
///
///     exec command [--opt -o]
///
@propertyWrapper
public final class Option<Value>: AnyOption, Sendable
    where Value: LosslessStringConvertible & Sendable
{
    /// The option's identifying name.
    public let name: String
    
    /// The option's short flag.
    public let help: String
    
    /// The option's help text when `--help` is passed in.
    public let short: Character?

    /// The option's shell completion action.
    ///
    /// See `CompletionAction` for more information and available actions.
    public let completion: CompletionAction

    /// Whether the option was passed into the command's signature or not.
    ///
    ///     app command --option "Hello World"
    ///     // signature.option.isPresent == true
    ///
    ///     app command
    ///     // signature.option.isPresent == false
    public var isPresent: Bool {
        get {
            _isPresent.withLockedValue { $0 }
        }
    }
    
    private let _isPresent: NIOLockedValueBox<Bool>

    public var projectedValue: Option<Value> {
        return self
    }

    public var initialized: Bool {
        switch self.value.withLockedValue({ $0 }) {
        case .initialized: return true
        case .uninitialized: return false
        }
    }

    public var wrappedValue: Value? {
        switch self.value.withLockedValue({ $0 }) {
        case let .initialized(value): return value
        case .uninitialized: fatalError("Option \(self.name) was not initialized")
        }
    }

    let value: NIOLockedValueBox<InputValue<Value?>>
    
    /// Creates a new `Option` with the `optionType` set to `.value`.
    ///
    ///     @Option(name: "verbose", short: "v", help: "Output debug logs")
    ///     var verbose: Bool?
    ///
    /// - Parameters:
    ///   - name: The option's identifying name that can be passed in to the command call.
    ///   - short: The short-hand for the flag that can be passed in to the command call.
    ///   - help: The option's help text when `--help` is passed in.
    ///   - completion: The option's shell completion action. See `CompletionAction` for more
    ///                 information and available actions.
    public init(
        name: String,
        short: Character? = nil,
        help: String = "",
        completion: CompletionAction = .default
    ) {
        self.name = name
        self.short = short
        self.help = help
        self.completion = completion
        self._isPresent = .init(false)
        self.value = .init(.uninitialized)
    }

    func load(from input: inout CommandInput) throws {
        let option = input.nextOption(name: self.name, short: self.short)
        self._isPresent.withLockedValue { $0 = option.passedIn }

        if let rawValue = option.value {
            guard let value = Value(rawValue) else {
                throw CommandError.invalidOptionType(self.name, type: Value.self)
            }
            self.value.withLockedValue { $0 = .initialized(value) }
        } else {
            self.value.withLockedValue { $0 = .initialized(nil) }
        }
    }
}

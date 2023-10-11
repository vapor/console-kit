import NIOConcurrencyHelpers

/// An argument for a console command
///
///     exec command <arg>
///
/// Used by the `Command.Arguments` associated type:
///
///     struct CowsayCommand: Command {
///         struct Arguments {
///             let message = Argument<String>(name: "message")
///         }
///         // ...
///     }
///
/// Fetch arguments using `CommandContext<Command>.argument(_:)`:
///
///     struct CowsayCommand: Command {
///         // ...
///         func run(using context: CommandContext<CowsayCommand>) throws -> Future<Void> {
///             let message = try context.argument(\.message)
///             // ...
///         }
///         // ...
///     }
///
/// See `Command` for more information.
@propertyWrapper
public final class Argument<Value>: AnyArgument, Sendable
    where Value: LosslessStringConvertible & Sendable
{
    /// The argument's identifying name.
    public let name: String
    
    /// The argument's help text when `--help` is passed in.
    public let help: String

    /// The argument's shell completion action.
    ///
    /// See `CompletionAction` for more information and available actions.
    public let completion: CompletionAction

    let value: NIOLockedValueBox<InputValue<Value>>

    public var projectedValue: Argument<Value> {
        return self
    }

    public var initialized: Bool {
        switch self.value.withLockedValue({ $0 }) {
        case .initialized: return true
        case .uninitialized: return false
        }
    }

    /// @propertyWrapper value
    public var wrappedValue: Value {
        switch self.value.withLockedValue({ $0 }) {
        case let .initialized(value): return value
        case .uninitialized: fatalError("Argument \(self.name) was not initialized")
        }
    }
    
    /// Creates a new `Argument`
    ///
    ///     @Argument(name: "count", help: "The number of times to run the command")
    ///     var count: Int
    ///
    /// - Parameters:
    ///   - name: The argument's identifying name.
    ///   - help: The arguments's help text when `--help` is passed in.
    ///   - completion: The argument's shell completion action. See `CompletionAction` for more
    ///                 information and available actions.
    public init(name: String, help: String = "", completion: CompletionAction = .default) {
        self.name = name
        self.help = help
        self.completion = completion
        self.value = .init(.uninitialized)
    }

    func load(from input: inout CommandInput) throws {
        guard let argument = input.nextArgument() else {
            throw CommandError.missingRequiredArgument(self.name)
        }
        guard let value = Value(argument) else {
            throw CommandError.invalidArgumentType(self.name, type: Value.self)
        }
        self.value.withLockedValue { $0 = .initialized(value) }
    }
}

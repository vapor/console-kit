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
public final class Argument<Value>: AnyArgument
    where Value: LosslessStringConvertible
{
    /// The arguments's help text when `--help` is passed in.
    public let help: String

    /// @propertyWrapper value
    public var wrappedValue: Value {
        guard let value = self.value else {
            fatalError("Argument \(self.name) was not initialized")
        }
        return value
    }

    var value: Value?
    var label: String?

    public convenience init() {
        self.init(help: "")
    }
    
    /// Creates a new `Argument`
    ///
    ///     @Argument(help: "The number of times to run the command")
    ///     var count: Int
    ///
    /// - Parameters:
    ///   - help: The arguments's help text when `--help` is passed in.
    public init(help: String) {
        self.help = help
    }

    func load(from input: inout CommandInput) throws {
        guard let argument = input.nextArgument() else {
            throw CommandError(identifier: "argument", reason: "Missing required argument: \(self.name)")
        }
        guard let value = Value(argument) else {
            throw CommandError(identifier: "argument", reason: "Could not convert argument for \(self.name) to \(Value.self)")
        }
        self.value = value
    }
}

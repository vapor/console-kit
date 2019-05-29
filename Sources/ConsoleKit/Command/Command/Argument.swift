/// A type-erased `Argument`.
public protocol AnyArgument {
    /// The argument's unique name.
    var name: String { get }
    
    /// The arguments's help text when `--help` is passed in.
    var help: String { get }
    
    /// The type that the argument value gets decoded to.
    var type: LosslessStringConvertible.Type { get }
}

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
public struct Argument<Value>: AnyArgument where Value: LosslessStringConvertible {
    /// The argument's unique name.
    public let name: String
    
    /// The arguments's help text when `--help` is passed in.
    public let help: String
    
    /// The type that the argument value gets decoded to.
    ///
    /// Required by `AnyArgument`.
    public var type: LosslessStringConvertible.Type {
        return Value.self
    }
    
    /// Creates a new `Argument`
    ///
    ///     let count = Argument<Int>(name: "count", help: "The number of times to run the command")
    ///
    /// - Parameters:
    ///   - name: The argument's unique name. Use this to get the argument value from the `CommandContext`.
    ///   - help: The arguments's help text when `--help` is passed in.
    public init(name: String, help: String = "") {
        self.name = name
        self.help = help
    }
}

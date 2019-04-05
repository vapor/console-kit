/// A type-erased `CommandRunnable`.
public protocol AnyCommandRunnable {
    /// An instance of the type that represents the command's valid inputs/signature.
    static var inputs: Inputs { get }
    
    /// Text that will be displayed when `--help` is passed.
    var help: String? { get }
    
    /// The type of runnable. See `CommandRunnableType`.
    var type: CommandRunnableType { get }
    
    /// Runs the command against the supplied input.
    func run(using context: AnyCommandContext) throws
}

/// Capable of being run on a `Console` using `Console.run(...)`.
///
/// - Note: This base protocol should not be used directly. Conform to `Command` or `CommandGroup` instead.
public protocol CommandRunnable: AnyCommandRunnable {
    /// The command's signiture.
    ///
    /// This type is made up of `Argument<T>` and `Option<T>` properties which
    /// are the command's accepted arguments and options.
    associatedtype Signature: Inputs
    
    /// An instance of the type that represents the command's valid signature.
    ///
    /// The type-specific implementation of `AnyCommandRunnable.inputs`.
    static var signature: Signature { get }
    
    /// Runs the command against the supplied input.
    func run(using context: CommandContext<Self>) throws
}

extension CommandRunnable {
    
    /// The default implementation of `AnyCommandRunnable.inputs`.
    ///
    /// - Returns: The `CommandRunnable.signature` value.
    public static var inputs: Inputs {
        return self.signature
    }
    
    /// The default implementation of `CommandRunnable.signature`.
    ///
    /// - Returns: A new instance of `CommandRunnable.Signature`.
    public static var signature: Signature {
        return Signature()
    }
    
    /// The default implementation for `AnyCommandRunnable.runt(using:)`.
    ///
    /// The context passed in is cast to `CommandContext<Signature>`, which is then passed into
    /// the `CommandRunable.run(using:)` method.
    ///
    /// - Throws: `ConsoleError.invalidSignature` is the context type-cast fails.
    public func run(using anyContext: AnyCommandContext) throws {
        let context = anyContext.context(command: Self.self)
        return try self.run(using: context)
    }
}

/// Supported runnable types.
public enum CommandRunnableType {
    
    /// See `CommandGroup`.
    case group(commands: Commands)
    
    /// See `Command`.
    case command(arguments: [AnyArgument])
}

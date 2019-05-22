/// A type-erased `CommandRunnable`.
public protocol AnyCommandRunnable {
    /// An instance of the type that represents the command's valid inputs/signature.
    var anySignature: CommandSignature { get }
    
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
    associatedtype Signature: CommandSignature

    /// A flag that defines whether the command arguments and options will be validated before running the command.
    ///
    /// If this property is set to `false`, then the command will run even if invalid arguments are passed in
    /// and the command will instead error out wen you try to access the invalid argument/option.
    static var strict: Bool { get }

    /// An instance of the type that represents the command's valid signature.
    ///
    /// The type-specific implementation of `AnyCommandRunnable.inputs`.
    var signature: Signature { get }
    
    /// Runs the command against the supplied input.
    func run(using context: CommandContext<Self>) throws
}

extension CommandRunnable {
    /// The default implementation for `CommandRunnable.strict`.
    ///
    /// - Returns: `false`.
    public static var strict: Bool {
        return false
    }

    /// The default implementation of `AnyCommandRunnable.inputs`.
    ///
    /// - Returns: The `CommandRunnable.signature` value.
    public var anySignature: CommandSignature {
        return self.signature
    }
    
    /// The default implementation for `AnyCommandRunnable.runt(using:)`.
    ///
    /// The context passed in is cast to `CommandContext<Signature>`, which is then passed into
    /// the `CommandRunable.run(using:)` method.
    ///
    /// - Throws: `ConsoleError.invalidSignature` is the context type-cast fails.
    public func run(using anyContext: AnyCommandContext) throws {
        let context = try anyContext.context(command: self)
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

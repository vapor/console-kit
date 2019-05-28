/// A type-erased `CommandContext`
public struct AnyCommandContext {
    /// The `Console` this command was run on.
    public var console: Console
    
    /// The parsed arguments (according to declared signature).
    public var arguments: [String: String]
    
    /// The parsed options (according to declared signature).
    public var options: [String: String]
    
    /// Create a new `AnyCommandContext`.
    public init(
        console: Console,
        arguments: [String: String],
        options: [String: String]
    ) {
        self.console = console
        self.arguments = arguments
        self.options = options
    }
    
    /// Creates an instance of `CommandContext<Command>` with the data from the current `AnyCommandContext` instance.
    ///
    /// - Parameter command: The `Command` generic type for the `CommandContext` instance.
    /// - Returns: A `CommandContext` with the `console`, `arguments`, and `options` from `AnyCommandContext`.
    public func context<Command>(command: Command)throws -> CommandContext<Command>
        where Command: CommandRunnable
    {
        return try CommandContext(
            console: self.console,
            command: command,
            arguments: self.arguments,
            options: self.options
        )
    }
    
    /// Creates an `AnyCommandContext`, parsing the values from the supplied `CommandInput`.
    ///
    /// - Parameters:
    ///   - input: The input from a command call that goes into the context's `argument` and `options`.
    ///   - console: The console instance used by the command.
    ///   - runnable: The command that will use the context.
    ///
    /// - Returns: The context for a command to run.
    static func make(
        from input: inout CommandInput,
        console: Console,
        for runnable: AnyCommandRunnable
    ) throws -> AnyCommandContext {
        var parsedArguments: [String: String] = [:]
        var parsedOptions: [String: String] = [:]
        
        for opt in runnable.anySignature.options {
            parsedOptions[opt.name] = try input.parse(option: opt)
        }
        
        let arguments: [AnyArgument]
        switch runnable.type {
        case .command(let a): arguments = a
        case .group: arguments = []
        }
        
        for arg in arguments {
            guard let value = try input.parse(argument: arg) else {
                throw CommandError(
                    identifier: "argumentRequired",
                    reason: "Argument `\(arg.name)` is required."
                )
            }
            parsedArguments[arg.name] = value
        }
        
        
        guard input.arguments.count == 0 else {
            let excess = input.arguments.joined(separator: " ")
            throw CommandError(
                identifier: "excessInput",
                reason: "Too many arguments or unsupported options were supplied: '\(excess)'"
            )
        }

        return AnyCommandContext(
            console: console,
            arguments: parsedArguments,
            options: parsedOptions
        )
    }
}

/// Contains required data for running a command such as the `Console` and `CommandInput`.
///
/// See `CommandRunnable` for more information.
public struct CommandContext<Command> where Command: CommandRunnable {
    /// The `Console` this command was run on.
    public let console: Console

    /// The command for this context.
    internal let command: Command

    /// A name/value map of the commands arguments that where passed in.
    public let rawArguments: [String: String]

    /// A name/value map of the commands options that where passed in.
    public let rawOptions: [String: String]

    #if swift(>=5.1)
    /// The parsed arguments (according to declared signature).
    public var arguments: Arguments {
        return Arguments(context: self)
    }

    /// The parsed options (according to declared signature).
    public var options: Options {
        return Options(context: self)
    }
    #endif
    
    /// Create a new `CommandContext`.
    fileprivate init(
        console: Console,
        command: Command,
        arguments: [String: String],
        options: [String: String]
    ) throws {
        let input = arguments.merging(options, uniquingKeysWith: { arg, opt in return arg })
        try command.signature.validate(input: input)

        self.console = console
        self.command = command
        self.rawArguments = arguments
        self.rawOptions = options
    }

    /// Gets an option passed into the command.
    ///
    /// If the option was not passed in and no default value was registered, then `nil` is returned.
    ///
    ///     let option = try context.option(\.foo)
    ///
    /// - Parameter path: The key-path of an `Option` in the parent command's `Signiture` to fetch.
    public func option<T>(_ path: KeyPath<Command.Signature, Option<T>>) -> T?
        where T: LosslessStringConvertible
    {
        guard let raw = self.rawOptions[self.command.signature[keyPath: path].name] else {
            return nil
        }
        guard let value = T.init(raw) else {
            fatalError("Unable to convert `\(raw)` to type `\(T.self)`")
        }
        return value
    }
    
    /// Requires an option, returning the value or throwing.
    ///
    ///     let option = try context.requireOption(\.foo)
    ///
    /// Use `.option(_:)` to access in a non-required manner.
    ///
    /// - Parameter path: The key-path of an `Option` in the parent command's `Signiture` to fetch.
    public func requireOption<T>(_ path: KeyPath<Command.Signature, Option<T>>) throws -> T
        where T: LosslessStringConvertible
    {
        guard let option = self.option(path) else {
            let name = self.command.signature[keyPath: path].name
            throw CommandError(identifier: "optionRequired", reason: "Option `\(name)` is required.")
        }

        return option
    }

    /// Accesses an argument by name. This will only throw if
    /// the argument was not properly declared in your signature.
    ///
    ///     let message = try context.argument(\.message)
    ///
    /// - Parameter path: The key-path of an `Argument` in the parent command's `Signiture` to fetch.
    public func argument<T>(_ path: KeyPath<Command.Signature, Argument<T>>) -> T
        where T: LosslessStringConvertible
    {
        let name = self.command.signature[keyPath: path].name
        guard let raw = self.rawArguments[name] else {
            fatalError("Argument `\(name)` is required.")
        }
        guard let value = T.init(raw) else {
            fatalError("Unable to convert `\(raw)` to type `\(T.self)`")
        }
        return value
    }

    /// See `AnyCommandContext.make(from:console:for:)`.
    static func make<Runnable>(
        from input: inout CommandInput,
        console: Console,
        for runnable: Runnable
    ) throws -> CommandContext<Runnable> where Runnable: CommandRunnable {
        return try AnyCommandContext.make(from: &input, console: console, for: runnable).context(command: runnable)
    }
}

#if swift(>=5.1)
extension CommandContext {
    /// A type safe container for a `CommandContext` options that supports dynamic access.
    @dynamicMemberLookup public struct Options {
        private let context: CommandContext<Command>

        fileprivate init(context: CommandContext<Command>) {
            self.context = context
        }

        /// Allows dynamic access to the context's options using the command's signature's keypaths.
        ///
        ///     struct Signature: CommandSignature {
        ///         let count = Option<Int>(name: "count")
        ///     }
        ///
        ///     context.count // Int
        ///
        /// - Note: This accessor should be used with a strict command, as it will trap if an error
        ///   occurs when reading the option.
        ///
        /// - Parameter path: The signature's keypath for the option to read.
        /// - Returns: The requested option's value, if one was passed in.
        public subscript<T>(dynamicMember path: KeyPath<Command.Signature, Option<T>>) -> T? {
            return try! self.context.option(path)
        }
    }

    /// A type safe container for a `CommandContext` arguments that supports dynamic access.
    @dynamicMemberLookup public struct Arguments {
        private let context: CommandContext<Command>

        fileprivate init(context: CommandContext<Command>) {
            self.context = context
        }

        /// Allows dynamic access to the context's arguments using the command's signature's keypaths.
        ///
        ///     struct Signature: CommandSignature {
        ///         let auth = Argument<Bool>(name: "auth")
        ///     }
        ///
        ///     context.auth // Bool
        ///
        /// - Note: This accessor should be used with a strict command, as it will trap if an error
        ///   occurs when reading the argument.
        ///
        /// - Parameter path: The signature's keypath for the argument to read.
        /// - Returns: The requested argument's value.
        public subscript<T>(dynamicMember path: KeyPath<Command.Signature, Argument<T>>) -> T {
            return try! self.context.argument(path)
        }
    }
}
#endif

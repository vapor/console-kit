/// Contains required data for running a command such as the `Console` and `CommandInput`.
///
/// See `CommandRunnable` for more information.
public struct CommandContext<Signiture> where Signiture: Inputs {
    /// The `Console` this command was run on.
    public var console: Console

    /// The parsed arguments (according to declared signature).
    public var arguments: [String: String]

    /// The parsed options (according to declared signature).
    public var options: [String: String]
    
    public let eventLoop: EventLoop

    private let signiture: Signiture
    
    /// Create a new `CommandContext`.
    public init(
        console: Console,
        arguments: [String: String],
        options: [String: String]
    ) {
        self.console = console
        self.arguments = arguments
        self.options = options
        self.eventLoop = console.eventLoopGroup.next()
        self.signiture = Signiture()
    }

    /// Gets an option passed into the command.
    ///
    /// If the option was not passed in and no default value was registered, then `nil` is returned.
    ///
    ///     let option = try context.option(\.foo)
    ///
    /// - parameters:
    ///   - path: The key-path of an `Option` in the parent command's `Signiture` to fetch.
    public func option<T>(_ path: KeyPath<Signiture, Option<T>>)throws -> T? where T: LosslessStringConvertible {
        guard let raw = self.options[self.signiture[keyPath: path].name] else {
            return nil
        }
        guard let value = T.init(raw) else {
            throw CommandError(identifier: "typeMismatch", reason: "Unable to convert `\(raw)` to type `\(T.self)`")
        }
        return value
    }
    
    /// Requires an option, returning the value or throwing.
    ///
    ///     let option = try context.requireOption(\.foo)
    ///
    /// Use `.option(_:)` to access in a non-required manner.
    ///
    /// - parameters:
    ///   - path: The key-path of an `Option` in the parent command's `Signiture` to fetch.
    public func requireOption<T>(_ path: KeyPath<Signiture, Option<T>>) throws -> T where T: LosslessStringConvertible {
        guard let option = try self.option(path) else {
            let name = self.signiture[keyPath: path].name
            throw CommandError(identifier: "optionRequired", reason: "Option `\(name)` is required.")
        }

        return option
    }

    /// Accesses an argument by name. This will only throw if
    /// the argument was not properly declared in your signature.
    ///
    ///     let message = try context.argument(\.message)
    ///
    /// - parameters:
    ///   - path: The key-path of an `Argument` in the parent command's `Signiture` to fetch.
    public func argument<T>(_ path: KeyPath<Signiture, Argument<T>>) throws -> T where T: LosslessStringConvertible {
        let name = self.signiture[keyPath: path].name
        guard let raw = arguments[name] else {
            throw CommandError(identifier: "argumentRequired", reason: "Argument `\(name)` is required.")
        }
        guard let value = T.init(raw) else {
            throw CommandError(identifier: "typeMismatch", reason: "Unable to convert `\(raw)` to type `\(T.self)`")
        }
        return value
    }

//    /// Creates a CommandContext, parsing the values from the supplied CommandInput.
//    static func make(
//        from input: inout CommandInput,
//        console: Console,
//        for runnable: CommandRunnable
//    ) throws -> CommandContext {
//        var parsedArguments: [String: String] = [:]
//        var parsedOptions: [String: String] = [:]
//
//        for opt in runnable.options {
//            parsedOptions[opt.name] = try input.parse(option: opt)
//        }
//
//        let arguments: [CommandArgument]
//        switch runnable.type {
//        case .command(let a): arguments = a
//        case .group: arguments = []
//        }
//
//        for arg in arguments {
//            guard let value = try input.parse(argument: arg) else {
//                throw CommandError(
//                    identifier: "argumentRequired",
//                    reason: "Argument `\(arg.name)` is required."
//                )
//            }
//            parsedArguments[arg.name] = value
//        }
//
//
//        guard input.arguments.count == 0 else {
//            throw CommandError(
//                identifier: "excessInput",
//                reason: "Too many arguments or unsupported options were supplied: \(input.arguments)"
//            )
//        }
//
//        return CommandContext(
//            console: console,
//            arguments: parsedArguments,
//            options: parsedOptions
//        )
//    }
}

/// The structure of the inputs that a command can take
///
///     struct Signature: Intpus:
///         let name = Argument<String>(name: "name")
///     }
public protocol Inputs {
    
    /// Creates a new instance of `Self`.
    ///
    /// This is required so a `CommandRunnable` can create an instance on the fly
    /// to things such as output help messages or fetch an argument value.
    init()
}

extension Inputs {
    
    /// Creates an `ArgumentGenerator` instance. This allows dynamically loading the
    /// argument name from it's property name in an `Inputs` instance.
    ///
    ///     struct Signature: Inputs {
    ///         let name = Signature.argument(String.self)
    ///     }
    ///
    /// - Parameters:
    ///   - type: The type that the argument value will be decoded to.
    ///   - help: The argument's help message. This gets output when the `--help,-h` flag is passed in.
    ///
    /// - Returns: An `ArgumentGenerator` type that can be called with the current `Inputs` instance
    ///   to get an `Argument<T>` instance.
    public static func argument<T>(_ type: T.Type, help: String? = nil) -> ArgumentGenerator<T> {
        let id = IDIterator.next()
        return ArgumentGenerator(id: id) { signature in
            let property = Mirror(reflecting: signature).children.first { child in
                return (child.value as? ArgumentGenerator<T>)?.id == id
            }
            guard let name = property?.label else {
                throw ConsoleError(identifier: "", reason: "Unable to find name for argument id ID `\(id)`")
            }
            return Argument(name: name, help: help)
        }
    }
    
    /// Creates an `OptiontGenerator` instance. This allows dynamically loading the
    /// option name from it's property name in an `Inputs` instance.
    ///
    ///     struct Signature: Inputs {
    ///         let verbose = Signature.flag()
    ///     }
    ///
    /// - Parameters:
    ///   - short: The short option that can be passed in instead of the full name.
    ///   - help: The argument's help message. This gets output when the `--help,-h` flag is passed in.
    ///
    /// - Returns: An `OptionGenerator` type that can be called with the current `Inputs` instance
    ///   to get an `Option<Bool>` instance.
    public static func flag(short: Character? = nil, help: String? = nil) -> OptionGenerator<Bool> {
        let id = IDIterator.next()
        return OptionGenerator(id: id) { signature in
            let property = Mirror(reflecting: signature).children.first { child in
                return (child.value as? OptionGenerator<Bool>)?.id == id
            }
            guard let name = property?.label else {
                throw ConsoleError(identifier: "", reason: "Unable to find name for argument id ID `\(id)`")
            }
            return Option(name: name, short: short, type: .flag, help: help)
        }
    }
    
    /// Creates an `OptiontGenerator` instance. This allows dynamically loading the
    /// option name from it's property name in an `Inputs` instance.
    ///
    ///     struct Signature: Inputs {
    ///         let url = Signature.option(String.self)
    ///     }
    ///
    /// - Parameters:
    ///   - type: The type that the argument value will be decoded to.
    ///   - short: The short option that can be passed in instead of the full name.
    ///   - default: The default value for the option if no value is passed in with the name.
    ///   - help: The argument's help message. This gets output when the `--help,-h` flag is passed in.
    ///
    /// - Returns: An `OptionGenerator` type that can be called with the current `Inputs` instance
    ///   to get an `Option<T>` instance.
    public static func option<T>(
        _ type: T.Type,
        short: Character? = nil,
        default: String? = nil,
        help: String? = nil
    ) -> OptionGenerator<T> {
        let id = IDIterator.next()
        return OptionGenerator(id: id) { signature in
            let property = Mirror(reflecting: signature).children.first { child in
                return (child.value as? OptionGenerator<T>)?.id == id
            }
            guard let name = property?.label else {
                throw ConsoleError(identifier: "", reason: "Unable to find name for argument id ID `\(id)`")
            }
            return Option(name: name, short: short, type: .value(default: `default`), help: help)
        }
    }
    
    /// Gets all the `Argument` propeties from an `Inputs` struct.
    ///
    /// Because the `Argument` struct is generic, we have to type-erase it and use `AnyArgument`.
    var arguments: [AnyArgument] {
        return Mirror(reflecting: self).children.compactMap { property -> AnyArgument? in
            guard let generator = property.value as? AnyArgumentGenerator else { return nil }
            return try? generator.anyGenerator(self)
        }
    }
    
    /// Gets all the `Option` propeties from an `Inputs` struct.
    ///
    /// Because the `Option` struct is generic, we have to type-erase it and use `AnyOption`.
    var options: [AnyOption] {
        return Mirror(reflecting: self).children.compactMap { property -> AnyOption? in
            guard let generator = property.value as? AnyOptionGenerator else { return nil }
            return try? generator.anyGenerator(self)
        }
    }
}

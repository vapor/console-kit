/// The structure of the inputs that a command can take
///
///     struct Signature: CommandSignature {
///         let name = Argument<String>(name: "name")
///     }
public protocol CommandSignature { }

extension CommandSignature {
    
    /// Gets all the `Argument` propeties from an `Inputs` struct.
    ///
    /// Because the `Argument` struct is generic, we have to type-erase it and use `AnyArgument`.
    var arguments: [AnyArgument] {
        return Mirror(reflecting: self).children.compactMap { property -> AnyArgument? in
            guard let argument = property.value as? AnyArgument else { return nil }
            return argument
        }
    }
    
    /// Gets all the `Option` propeties from an `Inputs` struct.
    ///
    /// Because the `Option` struct is generic, we have to type-erase it and use `AnyOption`.
    var options: [AnyOption] {
        return Mirror(reflecting: self).children.compactMap { property -> AnyOption? in
            guard let option = property.value as? AnyOption else { return nil }
            return option
        }
    }

    /// Verifies that the input for the command can be properly mapped to the commands signature (arguments and options).
    ///
    /// - Parameter input: The command input to verify
    /// - Returns: The input passed in. The returned value is discarable if you don't need it.
    /// - Throws:
    ///   - `missingArgument` if an argument value was not found in the input.
    ///   - `badInputType` if an argument's or option's value cannot be converted to the expected Swift type.
    @discardableResult
    func validate(input: [String: String])throws -> [String: String] {
        try self.arguments.forEach { argument in
            guard let value = input[argument.name] else {
                throw CommandError(identifier: "missingArgument", reason: "Missing expected argument `\(argument.name)`")
            }
            guard argument.type.init(value) != nil else {
                throw CommandError(
                    identifier: "badInputType",
                    reason: "Value for argument `\(argument.name)` must be convertable to type `\(argument.type)`"
                )
            }
        }

        try self.options.forEach { option in
            if let value = input[option.name] {
                guard option.valueType.init(value) != nil else {
                    throw CommandError(
                        identifier: "badInputType",
                        reason: "Value for option `\(option.name)` must be convertable to type `\(option.valueType)`"
                    )
                }
            }
        }

        return input
    }
}

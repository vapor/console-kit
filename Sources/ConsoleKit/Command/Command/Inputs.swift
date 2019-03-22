public protocol Inputs {
    init()
}

extension Inputs {
    
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
}

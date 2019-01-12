//
//  CommandContext+Extensions.swift
//  Async
//
//  Created by Luke Street on 12/30/18.
//

// Convenience functions used for type safe accessing of a `Command's` arguments, options, and flags
extension CommandContext {
    
    /// Uses case of `CommandOptions` as a key to retrieve an option if it has been provided
    ///
    /// - Parameter key: CommandOptions case corresponding to desired option
    /// - Returns: The corresponding option if it has been provided by the user
    public func option<Key: CommandOptions>(_ key: Key) -> String? {
        return option(key.caseName)
    }
    
    /// Uses case of `CommandFlags` as a key to retrieve whether the flag has been provided
    ///
    /// - Parameter key: CommandFlags case corresponding to desired flag
    /// - Returns: `true` if flag has been provided, `false` if not
    public func flag<Key: CommandFlags>(_ key: Key) -> Bool {
        return flag(key.caseName)
    }
    
    /// Uses case of `CommandArguments` as a key to retrieve an argument
    ///
    /// - Parameter key: CommandArguments case corresponding to desired argument
    /// - Returns: The corresponding argument
    public func argument<Key: CommandArguments>(_ key: Key) throws -> String {
        return try argument(key.caseName)
    }
    
    /// Uses string key to retrieve an option if it has been provided
    ///
    /// - Parameter key: String corresponding to desired option
    /// - Returns: The corresponding option if it has been provided by the user
    internal func option(_ key: String) -> String? {
        return options[key]
    }
    
    /// String as a key to retrieve whether the flag has been provided
    ///
    /// - Parameter key: String corresponding to desired flag
    /// - Returns: `true` if flag has been provided, `false` if not
    internal func flag(_ key: String) -> Bool {
        return options[key] != nil
    }
}

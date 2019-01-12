//
//  CommandOptions.swift
//  Async
//
//  Created by Luke Street on 12/30/18.
//

/// Describes type that may be used as a `Command's` options - best modeled as an enum
public protocol CommandOptions: CaseIterable {
    
    var name: String { get }
    
    var short: Character? { get }
    
    var defaultValue: String? { get }
    
    var help: [String] { get }
    
}

/// Default implementations for name, short, defaultValue, and help
extension CommandOptions {
    public var name: String { return self.caseName }
    public var short: Character? { return self.caseName.first }
    public var defaultValue: String? { return nil }
    public var help: [String] { return [] }
}

extension CommandOptions {
    
    /// Exposes all options defined by conforming type
    public static var options: [CommandOption] {
        return zip(
            Self.allCases.map(get(\.caseName)),
            Self.allCases.map(get(\Self.caseName.first)),
            Self.allCases.map(get(\.defaultValue)),
            Self.allCases.map(get(\.help))
        ).map(CommandOption.value)
    }
}

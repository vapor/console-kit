//
//  CommandFlags.swift
//  Async
//
//  Created by Luke Street on 12/30/18.
//

/// Describes type that may be used as a `Command's` options - best modeled as an enum
public protocol CommandFlags: CaseIterable {
    
    var name: String { get }
    
    var short: Character? { get }
    
    var help: [String] { get }
}

/// Default implementations for name, short, and help
extension CommandFlags {
    public var name: String { return self.caseName }
    public var short: Character? { return self.caseName.first }
    public var help: [String] { return [] }
}

extension CommandFlags {
    /// Exposes all flags defined by conforming type
    public static var flags: [CommandOption] {
        return zip(
            Self.allCases.map(get(\Self.caseName)),
            Self.allCases.map(get(\Self.caseName.first)),
            Self.allCases.map(get(\.help))
        ).map(CommandOption.flag)
    }
}

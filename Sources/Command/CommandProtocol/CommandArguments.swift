//
//  CommandArguments.swift
//  Async
//
//  Created by Luke Street on 12/30/18.
//

/// Describes type that may be used as a `Command's` arguments - best modeled as an enum
public protocol CommandArguments: CaseIterable {
    var name: String { get }
    var help: [String] { get }
}

extension CommandArguments {
    public var name: String { return self.caseName }
    public var help: [String] { return [] }
}

extension CommandArguments {
    /// Exposes all arguments defined by conforming type
    public static var arguments: [CommandArgument] {
        return zip(
            Self
                .allCases
                .map(get(\.caseName)),
            Self
                .allCases
                .map(get(\.help))
            )
            .map(CommandArgument.argument)
    }
}

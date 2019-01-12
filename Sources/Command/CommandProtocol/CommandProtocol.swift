//
//  CommandProtocol.swift
//  Async
//
//  Created by Luke Street on 12/30/18.
//


/// Allows a Command to define its options, arguments, and flags by simply supplying the desired types
///
/// Example:
///     struct CowsayCommand: CommandProtocol {
///
///         enum Arguments: CommandArguments {
///             case message
///         }
///
///         enum Options: CommandOptions {
///             case eyes, tongue
///         }
///
///         enum Flags: CommandFlags {}
///
///         var help: [String] {
///             return ["Generates ASCII picture of a cow with a message."]
///         }
///
///         func run(using context: CommandContext) throws -> Future<Void> {
///             let message = try context.argument(Argument.message)
///             let eyes = context.options(Optins.eyes) ?? "oo"
///             let tongue = context.options(Options.tongue) ?? " "
///             let padding = String(repeating: "-", count: message.count)
///             let text: String = """
///               \(padding)
///             < \(message) >
///               \(padding)
///                       \\   ^__^
///                        \\  (\(eyes)\\_______
///                           (__)\\       )\\/\\
///                             \(tongue)  ||----w |
///                                ||     ||
///             """
///             context.console.print(text)
///             return .done(on: context.container)
///         }
///     }
public protocol CommandProtocol: Command {
    associatedtype Options: CommandOptions
    associatedtype Arguments: CommandArguments
    associatedtype Flags: CommandFlags
}

extension CommandProtocol {
    
    /// Satisfy `arguments` requirement using associated `CommandArguments` type
    public var arguments: [CommandArgument] {
        return Arguments.arguments
    }
    
    /// Satisfy `options` requirement using associated `CommandOptions` and `CommandFlags` type
    public var options: [CommandOption] {
        return Options.options + Flags.flags
    }
}

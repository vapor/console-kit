/// The structure of the inputs that a command can take
///
///     struct Signature: CommandSignature {
///         @Argument
///         var name: String
///     }
///
public protocol CommandSignature {
    init()
}

extension CommandSignature {
    static var reference: Self {
        let reference = Self()
        return reference
    }

    var arguments: [AnyArgument] {
        return Mirror(reflecting: self).children
            .compactMap { $0.value as? AnyArgument }
    }

    var options: [AnyOption] {
        return Mirror(reflecting: self).children
            .compactMap { $0.value as? AnyOption }
    }

    var flags: [AnyFlag] {
        return Mirror(reflecting: self).children
            .compactMap { $0.value as? AnyFlag }
    }

    var values: [AnySignatureValue] {
        return Mirror(reflecting: self).children
            .compactMap { $0.value as? AnySignatureValue }
    }
    
    public init(from input: inout CommandInput) throws {
        self.init()
        try self.values.forEach { try $0.load(from: &input) }
    }
}

extension CommandSignature {
    func outputSignatureHelp(using context: inout CommandContext) {
        let names = self.options.map { $0.name }
            + self.arguments.map { $0.name }
            + self.flags.map { $0.name }

        let padding = names.longestCount + 2
        if self.arguments.count > 0 {
            context.console.print()
            context.console.output("Arguments:".consoleText(.info))
            for argument in self.arguments {
                context.console.outputHelpListItem(
                    name: argument.name,
                    help: argument.help,
                    style: .info,
                    padding: padding
                )
            }
        }

        if self.options.count > 0 {
            context.console.print()
            context.console.output("Options:".consoleText(.info))
            for option in self.options {
                context.console.outputHelpListItem(
                    name: option.name,
                    help: option.help,
                    style: .success,
                    padding: padding
                )
            }
        }

        if self.flags.count > 0 {
            context.console.print()
            context.console.output("Flags:".consoleText(.info))
            for option in self.flags {
                context.console.outputHelpListItem(
                    name: option.name,
                    help: option.help,
                    style: .success,
                    padding: padding
                )
            }
        }
    }
    
    func outputUsage(using context: inout CommandContext) {
        context.console.output(
            "Usage: ".consoleText(.info) +
            context.usageDescriptor.consoleText() +
            " ",
            newLine: false
        )
        
        for argument in self.arguments {
            context.console.output(("<" + argument.name + "> ").consoleText(.warning), newLine: false)
        }

        for option in self.options {
            if let short = option.short {
                context.console.output("[--\(option.name),-\(short)] ".consoleText(.success), newLine: false)
            } else {
                context.console.output("[--\(option.name)] ".consoleText(.success), newLine: false)
            }
        }

        for flag in self.flags {
            if let short = flag.short {
                context.console.output("[--\(flag.name),-\(short)] ".consoleText(.info), newLine: false)
            } else {
                context.console.output("[--\(flag.name)] ".consoleText(.info), newLine: false)
            }
        }
        
        context.console.output(" [--help,-h]".consoleText(.success))
    }
}

enum InputValue<T> {
    case initialized(T)
    case uninitialized
}

internal protocol AnySignatureValue: AnyObject {
    var help: String { get }
    var name: String { get }
    var initialized: Bool { get }

    func load(from input: inout CommandInput) throws

    /// Returns the information used by the completion-generation code to provide
    /// shell completions for command signature values and their arguments.
    var completionInfo: CompletionSignatureValueInfo { get }
}

internal protocol AnyArgument: AnySignatureValue { }
internal protocol AnyOption: AnySignatureValue {
    var short: Character? { get }
}
internal protocol AnyFlag: AnySignatureValue {
    var short: Character? { get }
}

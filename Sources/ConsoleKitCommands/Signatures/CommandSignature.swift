/// The structure of the inputs that a command can take
///
///     struct Signature: CommandSignature {
///         @Argument
///         var name: String
///     }
///
public protocol CommandSignature: Sendable {
    init()
}

extension CommandSignature {
    var arguments: [any AnyArgument] {
        return Mirror(reflecting: self).children
            .compactMap { $0.value as? (any AnyArgument) }
    }

    var options: [any AnyOption] {
        return Mirror(reflecting: self).children
            .compactMap { $0.value as? (any AnyOption) }
    }

    var flags: [any AnyFlag] {
        return Mirror(reflecting: self).children
            .compactMap { $0.value as? (any AnyFlag) }
    }

    var values: [any AnySignatureValue] {
        return Mirror(reflecting: self).children
            .compactMap { $0.value as? (any AnySignatureValue) }
    }
    
    public init(from input: inout CommandInput) throws {
        self.init()
        try self.values.forEach { try $0.load(from: &input) }
    }
}

enum InputValue<T: Sendable>: Sendable {
    case initialized(T)
    case uninitialized
}

internal protocol AnySignatureValue: AnyObject, Sendable {
    var help: String { get }
    var name: String { get }
    var initialized: Bool { get }

    func load(from input: inout CommandInput) throws

    /// Returns the information used by the completion-generation code to provide
    /// shell completions for command signature values and their arguments.
    var completionInfo: CompletionSignatureValueInfo { get }
}

internal protocol AnyArgument: AnySignatureValue {}
internal protocol AnyOption: AnySignatureValue {
    var short: Character? { get }
}
internal protocol AnyFlag: AnySignatureValue {
    var short: Character? { get }
}

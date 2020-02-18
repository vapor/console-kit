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

enum InputValue<T> {
    case initialized(T)
    case uninitialized
}

internal protocol AnySignatureValue: class {
    var help: String { get }
    var name: String { get }
    var initialized: Bool { get }

    func load(from input: inout CommandInput) throws

    var completionInfo: CompletionArgumentInfo { get }
}

internal protocol AnyArgument: AnySignatureValue { }
internal protocol AnyOption: AnySignatureValue {
    var short: Character? { get }
}
internal protocol AnyFlag: AnySignatureValue {
    var short: Character? { get }
}

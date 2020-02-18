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
    var short: Character? { get }
    var initialized: Bool { get }

    var hasLabel: Bool { get }

    func completionExpression(for shell: Shell) -> String

    func load(from input: inout CommandInput) throws
}

extension AnySignatureValue {

    var hasLabel: Bool { true }

    var labels: [String] {
        guard self.hasLabel else { return [] }
        let long = "--\(self.name)"
        guard let short = self.short.map({ "-\($0)" }) else { return [long] }
        return [long, short]
    }
}

internal protocol AnyArgument: AnySignatureValue { }

extension AnyArgument {
    var short: Character? { nil }
    var hasLabel: Bool { false }
}

internal protocol AnyOption: AnySignatureValue { }
internal protocol AnyFlag: AnySignatureValue { }

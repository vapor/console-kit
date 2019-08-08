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
        reference.initializeLabels()
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

    func initializeLabels() {
        for child in Mirror(reflecting: self).children {
            if let value = child.value as? AnySignatureValue {
                value.label = child.label
                    .flatMap { String($0.dropFirst()) }
            }
        }
    }

    init(from input: inout CommandInput) throws {
        self.init()
        self.initializeLabels()
        try self.values.forEach { try $0.load(from: &input) }
    }
}

internal protocol AnySignatureValue: class {
    var label: String? { get set }
    var help: String { get }
    func load(from input: inout CommandInput) throws
}

internal extension AnySignatureValue {
    var name: String {
        guard let name = self.label else {
            fatalError("Labels were not initialized")
        }
        return name
    }
}

internal protocol AnyArgument: AnySignatureValue { }
internal protocol AnyOption: AnySignatureValue {
    var short: Character? { get }
}
internal protocol AnyFlag: AnySignatureValue {
    var short: Character? { get }
}

/// A `Sendable` version of the standard library's `AnyHashable` type.
public struct AnySendableHashable: @unchecked Sendable, Hashable, ExpressibleByStringLiteral {
    // Note: @unchecked Sendable since there's no way to express that `wrappedValue` is Sendable, even though we ensure that it is in the init.
    let wrappedValue: AnyHashable
    
    public init(_ wrappedValue: some Hashable & Sendable) {
        self.wrappedValue = AnyHashable(wrappedValue)
    }
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension AnySendableHashable: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public var description: String { self.wrappedValue.description }
    public var debugDescription: String { self.wrappedValue.debugDescription }
    public var customMirror: Mirror { self.wrappedValue.customMirror }
}

extension Dictionary where Key == AnySendableHashable {
    public subscript(key: some Hashable & Sendable) -> Value? {
        get { self[AnySendableHashable(key)] }
        set { self[AnySendableHashable(key)] = newValue }
    }
}

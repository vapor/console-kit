import NIO

/// Dynamically creats unique identifiers for `ArgumentGenerator` and `OptionGenerator` instances.
internal final class IDIterator {
    static let instance: ThreadSpecificVariable<IDIterator> = .init(value: IDIterator())
    
    static func next() -> UInt8 {
        return self.instance.currentValue?.next() ?? 0
    }
    
    var current: UInt8 = 0
    
    init () {}
    
    /// Gets the next ID.
    func next() -> UInt8 {
        defer { self.current += 1 }
        return current
    }
}

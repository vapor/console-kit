public protocol Argument {
    var name: String { get }
    var help: [String] { get }
}

extension Sequence where Iterator.Element == Argument {
    public var values: [Value] {
        #if swift(>=4.1)
        return compactMap { $0 as? Value }
        #else
        return flatMap { $0 as? Value }
        #endif
    }

    public var options: [Option] {
        #if swift(>=4.1)
        return compactMap { $0 as? Option }
        #else
        return flatMap { $0 as? Option }
        #endif
    }
}

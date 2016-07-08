public protocol Argument {
    var name: String { get }
    var help: [String] { get }
}

extension Sequence where Iterator.Element == Argument {
    public var values: [Value] {
        return flatMap { $0 as? Value }
    }

    public var options: [Option] {
        return flatMap { $0 as? Option }
    }
}

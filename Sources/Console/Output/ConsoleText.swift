/// A collection of `ConsoleTextFragment`.
public struct ConsoleText: RandomAccessCollection, ExpressibleByArrayLiteral, ExpressibleByStringLiteral, CustomStringConvertible {
    /// See `Collection`.
    public var startIndex: Int {
        return fragments.startIndex
    }

    /// See `Collection`.
    public var endIndex: Int {
        return fragments.endIndex
    }

    /// See `Collection`.
    public func index(after i: Int) -> Int {
        return i + 1
    }

    /// See `CustomStringConvertible`.
    public var description: String {
        return fragments.map { $0.string }.joined()
    }

    /// See `ExpressibleByArrayLiteral`.
    public init(arrayLiteral elements: ConsoleTextFragment...) {
        self.fragments = elements
    }


    /// See `ExpressibleByArrayLiteral`.
    public init(stringLiteral string: String) {
        self.fragments = [.init(string: string)]
    }

    /// One or more `ConsoleTextFragment`s making up this `ConsoleText.
    public var fragments: [ConsoleTextFragment]

    /// Creates a new `ConsoleText`.
    public init(fragments: [ConsoleTextFragment]) {
        self.fragments = fragments
    }

    /// See `Collection`.
    public subscript(position: Int) -> ConsoleTextFragment {
        return fragments[position]
    }

    public static let newLine: ConsoleText = "\n"
}

public struct ConsoleTextFragment {
    public var string: String
    public var style: ConsoleStyle

    /// Creates a new `ConsoleTextFragment`.
    public init(string: String, style: ConsoleStyle = .plain) {
        self.string = string
        self.style = style
    }
}

public func +(lhs: ConsoleText, rhs: ConsoleText) -> ConsoleText {
    return ConsoleText(fragments: lhs.fragments + rhs.fragments)
}


public func +=(lhs: inout ConsoleText, rhs: ConsoleText) {
    lhs = lhs + rhs
}

extension String {
    public func consoleText(_ style: ConsoleStyle = .plain) -> ConsoleText {
        return [ConsoleTextFragment(string: self, style: style)]
    }
    public func consoleText(color: ConsoleColor? = nil, background: ConsoleColor? = nil, isBold: Bool = false) -> ConsoleText {
        let style = ConsoleStyle(color: color, background: background, isBold: isBold)
        return consoleText(style)
    }
}

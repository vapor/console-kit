extension String {
    /// Converts this `String` to `ConsoleText`.
    ///
    ///     console.output("Hello, " + "world!".consoleText(color: .green))
    ///
    /// See `ConsoleStyle` for more information.
    public func consoleText(_ style: ConsoleStyle = .plain) -> ConsoleText {
        return [ConsoleTextFragment(string: self, style: style)]
    }

    /// Converts this `String` to `ConsoleText`.
    ///
    ///     console.output("Hello, " + "world!".consoleText(color: .green))
    ///
    /// See `ConsoleStyle` for more information.
    public func consoleText(color: ConsoleColor? = nil, background: ConsoleColor? = nil, isBold: Bool = false) -> ConsoleText {
        let style = ConsoleStyle(color: color, background: background, isBold: isBold)
        return consoleText(style)
    }
}

/// A collection of `ConsoleTextFragment`s. Represents stylized text that can be outputted
/// to a `Console`.
///
///     let text: ConsoleText = "Hello, " + "world".consoleText(color: .green)
///
/// See `Console.output(_:newLine:)` for more information.
public struct ConsoleText: RandomAccessCollection, ExpressibleByArrayLiteral, ExpressibleByStringLiteral, CustomStringConvertible, Sendable {
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


    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral string: String) {
        if string.count > 0 {
            self.fragments = [.init(string: string)]
        } else {
            self.fragments = []
        }
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

    /// `\n` character with plain styling.
    public static let newLine: ConsoleText = "\n"
}

// MARK: Operators

/// Appends a `ConsoleText` to another `ConsoleText`.
///
///     let text: ConsoleText = "Hello, " + "world!"
///
public func +(lhs: ConsoleText, rhs: ConsoleText) -> ConsoleText {
    return ConsoleText(fragments: lhs.fragments + rhs.fragments)
}

/// Appends a `ConsoleText` to another `ConsoleText` in-place.
///
///     var text: ConsoleText = "Hello, "
///     text += "world!"
///
public func +=(lhs: inout ConsoleText, rhs: ConsoleText) {
    lhs = lhs + rhs
}

extension ConsoleText: ExpressibleByStringInterpolation {
    public init(stringInterpolation: StringInterpolation) {
        self.fragments = stringInterpolation.fragments
    }

    public struct StringInterpolation: StringInterpolationProtocol {
        public var fragments: [ConsoleTextFragment]

        public init(literalCapacity: Int, interpolationCount: Int) {
            self.fragments = []
            self.fragments.reserveCapacity(literalCapacity)
        }

        public mutating func appendLiteral(_ literal: String) {
            self.fragments.append(.init(string: literal))
        }

        public mutating func appendInterpolation(
            _ value: String,
            style: ConsoleStyle = .plain
        ) {
            self.fragments.append(.init(string: value, style: style))
        }
        
        public mutating func appendInterpolation(
            _ value: String,
            color: ConsoleColor?,
            background: ConsoleColor? = nil,
            isBold: Bool = false
        ) {
            self.fragments.append(.init(string: value, style: .init(
                color: color,
                background: background,
                isBold: isBold
            )))
        }
    }
}

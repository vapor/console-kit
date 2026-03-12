/// A result builder for creating logger fragments in a declarative way.
///
/// This allows you to build complex logger fragment combinations using Swift's result builder syntax.
///
/// You can add spaces between fragments by specifying the number of spaces as the generic parameter.
/// For example, `@LoggerFragmentBuilder<1>` will add a single space between fragments,
/// while `@LoggerFragmentBuilder<0>` will not add any spaces.
@available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, macCatalyst 26.0, visionOS 26.0, *)
@resultBuilder
public enum LoggerFragmentBuilder<let spaces: Int> {
    /// Build an expression from a single logger fragment.
    public static func buildExpression<F: LoggerFragment>(_ fragment: F) -> F {
        fragment
    }

    /// Build an expression from a string literal, creating a ``LiteralFragment``.
    public static func buildExpression(_ literal: String) -> LiteralFragment {
        LiteralFragment(literal)
    }

    /// Build a block from a single logger fragment.
    public static func buildBlock<F: LoggerFragment>(_ fragment: F) -> F {
        fragment
    }

    /// Build a block from no fragments (empty block).
    public static func buildBlock() -> LiteralFragment {
        LiteralFragment("")
    }

    /// Build the first fragment in a partial block.
    public static func buildPartialBlock<F: LoggerFragment>(first: F) -> F {
        first
    }

    /// Combine accumulated fragments with the next fragment using ``AndFragment``.
    public static func buildPartialBlock<F1: LoggerFragment, F2: LoggerFragment>(
        accumulated: F1,
        next: F2
    ) -> AndFragment<F1, SeparatorFragment<F2>> {
        AndFragment(accumulated, next.separated(String(repeating: " ", count: spaces)))
    }

    /// Handle optional fragments using an optional wrapper.
    public static func buildOptional<F: LoggerFragment>(_ fragment: F?) -> OptionalFragment<F> {
        OptionalFragment(fragment)
    }

    /// Build either branch for if-else statements (first branch).
    public static func buildEither<F: LoggerFragment>(first fragment: F) -> F {
        fragment
    }

    /// Build either branch for if-else statements (second branch).
    public static func buildEither<F: LoggerFragment>(second fragment: F) -> F {
        fragment
    }

    /// Build an array of fragments using a custom ``ArrayFragment``.
    public static func buildArray<F: LoggerFragment>(_ fragments: [F]) -> ArrayFragment<F> {
        ArrayFragment(fragments, separator: String(repeating: " ", count: spaces))
    }
}

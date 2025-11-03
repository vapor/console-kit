import ConsoleKit

/// A result builder for creating logger fragments in a declarative way.
///
/// This allows you to build complex logger fragment combinations using Swift's result builder syntax.
/// Like ``LoggerFragmentBuilder``, but automatically separates fragments with a space.
@resultBuilder
public enum LoggerSpacedFragmentBuilder {
    /// Build an expression from a single logger fragment.
    public static func buildExpression<F: LoggerFragment>(_ fragment: F) -> F {
        LoggerFragmentBuilder.buildExpression(fragment)
    }

    /// Build an expression from a string literal, creating a ``LiteralFragment``.
    public static func buildExpression(_ literal: String) -> LiteralFragment {
        LoggerFragmentBuilder.buildExpression(literal)
    }

    /// Build a block from a single logger fragment.
    public static func buildBlock<F: LoggerFragment>(_ fragment: F) -> F {
        LoggerFragmentBuilder.buildBlock(fragment)
    }

    /// Build a block from no fragments (empty block).
    public static func buildBlock() -> LiteralFragment {
        LoggerFragmentBuilder.buildBlock()
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
        AndFragment(accumulated, next.separated(" "))
    }

    /// Handle optional fragments using an optional wrapper.
    public static func buildOptional<F: LoggerFragment>(_ fragment: F?) -> OptionalFragment<F> {
        LoggerFragmentBuilder.buildOptional(fragment)
    }

    /// Build either branch for if-else statements (first branch).
    public static func buildEither<F: LoggerFragment>(first fragment: F) -> F {
        LoggerFragmentBuilder.buildEither(first: fragment)
    }

    /// Build either branch for if-else statements (second branch).
    public static func buildEither<F: LoggerFragment>(second fragment: F) -> F {
        LoggerFragmentBuilder.buildEither(second: fragment)
    }

    /// Build an array of fragments using a custom ``ArrayFragment``.
    public static func buildArray<F: LoggerFragment>(_ fragments: [F]) -> ArrayFragment<F> {
        ArrayFragment(fragments, separator: " ")
    }
}

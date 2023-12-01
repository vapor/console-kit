/// Supported methods for clearing the `Console`.
///
/// See `Console.clear(_:)`
public enum ConsoleClear {
    /// Clears the entire viewable area of the `Console`.
    case screen
    /// Deletes the last line that was printed to the `Console`.
    case line
}

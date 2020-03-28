extension Console {
    /// Requests input from the console after displaying a prompt.
    ///
    ///     let answer = console.ask("How are you doing?")
    ///     console.output("You said: " + answer.consoleText())
    ///
    /// Input will be read until the first newline. See `Console.input(isSecure:)`. The above code outputs:
    ///
    ///     How are you doing?
    ///     > great!
    ///     You said: great!
    ///
    /// - parameters:
    ///     - prompt: Text to display before asking for input.
    ///     - isSecure: See `Console.input(isSecure:)`
    /// - returns: Input `String`. entered in response to the prompt.
    ///
    /// - note: If EOF appears from the terminal's input, the result is an empty
    ///   string. It is the caller's responsibility to avoid infinite retries in
    ///   such a case, such as in `Console.confirm(_:)`.
    public func ask(_ prompt: ConsoleText, isSecure: Bool = false) -> String {
        output(prompt + .newLine + "> ".consoleText(.info), newLine: false)
        return input(isSecure: isSecure)
    }
}

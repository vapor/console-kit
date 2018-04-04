extension Console {
    /// Requests input from the console
    /// after displaying the desired prompt.
    public func ask(_ prompt: ConsoleText, isSecure: Bool = false) -> String {
        output(prompt + .newLine + "> ".consoleText(.info), newLine: false)
        return input(isSecure: isSecure)
    }
}

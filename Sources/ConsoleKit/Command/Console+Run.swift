/// Adds the ability to run `Command`s on a `Console`.
extension Console {
    /// Runs a `CommandRunnable` (`CommandGroup` or `Command`) of commands on this `Console` using the supplied `CommandInput`.
    ///
    ///     try console.run(group, input: &env.commandInput, on: container).wait()
    ///
    /// The `CommandInput` will be mutated, removing any used `CommandOption`s and `CommandArgument`s.
    /// If any excess input is left over after checking the command's signature, an error will be thrown.
    ///
    /// - parameters:
    ///     - runnable: `CommandGroup` or `Command` to run.
    ///     - input: Mutable `CommandInput` to parse `CommandOption`s and `CommandArgument`s from.
    /// - returns: A `Future` that will complete when the command finishes.
    public func run(_ command: AnyCommand, input: CommandInput) throws {
        // create new context
        var context = CommandContext(console: self, input: input)

        // parse global signature
        let signature = try GlobalSignature(from: &context.input)

        // check -n and -y flags.
        if signature.no {
            self.confirmOverride = false
        } else if signature.yes {
            self.confirmOverride = true
        }

        if signature.help {
            try command.outputHelp(using: &context)
        } else if signature.autocomplete {
            try command.outputAutoComplete(using: &context)
        } else {
            return try command.run(using: &context)
        }
    }
}

private struct GlobalSignature: CommandSignature {
    @Flag(name: "no", short: "n", help: "Automatically answers no to all confirmations")
    var no: Bool

    @Flag(name: "yes", short: "y", help: "Automatically answers yes to all confirmations")
    var yes: Bool

    @Flag(name: "help", short: "h", help: "Displays instructions for the supplied command")
    var help: Bool

    @Flag(name: "autocomplete", help: "Produces output for bash autocomplete")
    var autocomplete: Bool

    init() { }
}

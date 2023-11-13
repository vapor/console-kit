import protocol ConsoleKitTerminal.Console

/// Adds the ability to run `Command`s on a `Console`.
extension Console {
    /// Runs an `AnyCommand` (`CommandGroup` or `Command`) of commands on this `Console` using the supplied `CommandInput`.
    ///
    ///     try console.run(group, input: commandInput)
    ///
    /// The `CommandInput` will be mutated, removing any used `CommandOption`s and `CommandArgument`s.
    /// If any excess input is left over after checking the command's signature, an error will be thrown.
    ///
    /// - parameters:
    ///     - command: `CommandGroup` or `Command` to run.
    ///     - input: `CommandInput` to parse `CommandOption`s and `CommandArgument`s from.
    public func run(_ command: any AnyCommand, input: CommandInput) throws {
        // create new context
        try self.run(command, with: CommandContext(console: self, input: input))
    }

    /// Runs an `AnyCommand` (`CommandGroup` or `Command`) of commands on this `Console` using the supplied `CommandContext`.
    ///
    ///     try console.run(group, with: context)
    ///
    /// - parameters:
    ///     - runnable: `CommandGroup` or `Command` to run.
    ///     - input: `CommandContext` to parse `CommandOption`s and `CommandArgument`s from.
    public func run(_ command: any AnyCommand, with context: CommandContext) throws {
        // make copy of context
        var context = context

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
    
    /// Runs an `AnyAsyncCommand` (`AsyncCommandGroup` or `AsyncCommand`) of commands on this `Console` using the supplied `CommandInput`.
    ///
    ///     try await console.run(group, input: commandInput)
    ///
    /// The `CommandInput` will be mutated, removing any used `CommandOption`s and `CommandArgument`s.
    /// If any excess input is left over after checking the command's signature, an error will be thrown.
    ///
    /// - parameters:
    ///     - command: `AsyncCommandGroup` or `AsyncCommand` to run.
    ///     - input: `CommandInput` to parse `CommandOption`s and `CommandArgument`s from.
    public func run(_ command: any AnyAsyncCommand, input: CommandInput) async throws {
        // create new context
        try await self.run(command, with: CommandContext(console: self, input: input))
    }

    /// Runs an `AnyAsyncCommand` (`AsyncCommandGroup` or `AsyncCommand`) of commands on this `Console` using the supplied `CommandContext`.
    ///
    ///     try console.run(group, with: context)
    ///
    /// - parameters:
    ///     - runnable: `AsyncCommandGroup` or `AsyncCommand` to run.
    ///     - input: `CommandContext` to parse `CommandOption`s and `CommandArgument`s from.
    public func run(_ command: any AnyAsyncCommand, with context: CommandContext) async throws {
        // make copy of context
        var context = context

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
          return try await command.run(using: &context)
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

import Console

extension OutputConsole {
    /// Outputs autocomplete for a command.
    public func outputAutocomplete(for runnable: CommandRunnable, executable: String) throws {
        var autocomplete: [String] = []
        switch runnable.type {
        case .command(let arguments): autocomplete += arguments.map { $0.name }
        case .group(let commands): autocomplete += commands.keys
        }
        autocomplete += runnable.options.map { "--" + $0.name }
        output(autocomplete.joined(separator: " "), style: .plain)
    }
}

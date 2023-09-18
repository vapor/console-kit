import Foundation

struct GenerateAutocompleteCommand: Command {
    var help: String { "Generate shell completion scripts for the executable" }

    var rootCommand: (any AnyCommand)?

    init(rootCommand: (any AnyCommand)? = nil) {
        self.rootCommand = rootCommand
    }

    struct Signature: CommandSignature {

        @Option(
            name: "shell",
            short: "s",
            help: """
            Generate a completion script for SHELL [ \(Shell.allCases.map { "\($0)" }.joined(separator: " | ")) ].
            Defaults to the "SHELL" environment variable if possible.
            """,
            completion: .values(of: Shell.self)
        )
        var shell: Shell?

        @Option(
            name: "output",
            short: "o",
            help: """
            Write the completion script to the file at OUTPUT, overwriting its contents.
            Defaults to printing to stdout.
            """,
            completion: .files()
        )
        var output: String?

        @Flag(name: "quiet", short: "q", help: "Suppress any informational console output")
        var quiet: Bool
    }

    func run(using context: CommandContext, signature: Signature) throws {

        guard let rootCommand = self.rootCommand else { fatalError("`rootCommand` was not initialized") }
        guard let shell = signature.shell ?? self.environmentShell() else {
            throw CommandError.missingRequiredArgument(signature.$shell.name)
        }

        // Reset the executable path
        var context = context
        context.input.executablePath = [context.input.executablePath.first!]

        let script = rootCommand.renderCompletionScript(using: context, shell: shell)

        if let output = signature.output, let contents = script.data(using: .utf8) {
            let outputUrl = URL(fileURLWithPath: output)
            try contents.write(to: outputUrl)
            guard !signature.quiet else { return }
            context.console.info("\(shell) completion script written to `\(output)`")
            switch shell {
            case .bash:
                context.console.info("Add the following line to your `~/.bashrc` or `~/.bash_profile` to enable autocompletion:")
                context.console.output("[ -f \"\(output)\" ] && . \"\(output)\"", style: .plain)
            case .zsh:
                let filename = outputUrl.lastPathComponent
                let expectedFilename = "_\(context.input.executableName)"
                if filename != expectedFilename {
                    context.console.warning(
                        "Note: The zsh completion script should be named `\(expectedFilename)` to be registered by `compinit`"
                    )
                }
                let directory = outputUrl.deletingLastPathComponent().path
                context.console.info(
                    "Add the following line to your `~/.zshrc` to add the `\(directory)` directory to your `fpath`:"
                )
                context.console.output("fpath=(\"\(directory)\" $fpath)", style: .plain)
            }
        } else {
            context.console.output(script, style: .plain)
        }
    }

    /// Returns a `Shell` value created from the process's environment variable `"SHELL"`.
    private func environmentShell() -> Shell? {
        guard
            let shellPath = ProcessInfo.processInfo.environment["SHELL"],
            let shellName = shellPath.split(separator: "/").last,
            let shell = Shell(rawValue: String(shellName))
            else { return nil }
        return shell
    }
}

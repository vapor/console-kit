import Foundation

struct GenerateAutocompleteCommand: Command {

    var help: String { "Generate shell completion scripts for the executable" }

    var rootCommand: AnyCommand?

    init(rootCommand: AnyCommand? = nil) {
        self.rootCommand = rootCommand
    }

    struct Signature: CommandSignature {

        @Option(
            name: "shell",
            short: "s",
            help: """
            Generate completion script for SHELL [ \(Shell.allCases.map { "\($0)" }.joined(separator: " | ")) ].
            Defaults to the "SHELL" environment variable if possible.
            """,
            completion: .values(of: Shell.self)
        )
        var shell: Shell?

        @Option(
            name: "output",
            short: "o",
            help: """
            Write output to file at OUTPUT.
            Defaults to printing to stdout.
            """,
            completion: .files()
        )
        var output: String?
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
            try contents.write(to: URL(fileURLWithPath: output))
            context.console.info("\n\(shell) completion script written to \(output)")
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

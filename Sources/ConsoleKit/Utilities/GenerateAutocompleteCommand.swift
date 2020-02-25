import Foundation

struct GenerateAutocompleteCommand: Command {

    var help: String { "Generate shell completion scripts for the executable" }

    var rootCommand: AnyCommand?

    init(rootCommand: AnyCommand? = nil) {
        self.rootCommand = rootCommand
    }

    struct Signature: CommandSignature {

        @Argument(
            name: "shell",
            help: "The shell to target (\(Shell.allCases.map { "\($0)" }.joined(separator: "|")))",
            completion: .values(of: Shell.self)
        )
        var shell: Shell
    }

    func run(using context: CommandContext, signature: Signature) throws {
        guard let rootCommand = self.rootCommand else { fatalError("`rootCommand` was not initialized") }
        // Reset the executable path
        var context = context
        context.input.executablePath = [context.input.executablePath.first!]
        let script = rootCommand.renderCompletionScript(using: context, shell: signature.shell)
        context.console.output(script, style: .plain)
    }
}

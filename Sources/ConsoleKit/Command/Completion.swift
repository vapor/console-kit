/// Shell completion implementations.
public enum Shell {
    case bash
    case zsh
}

extension AnyCommand {

    /// Returns the complete contents of a completion script for the given `shell`
    /// for `self` and, recursively, all of its descendent subcommands.
    public func renderCompletionScript(using context: CommandContext, shell: Shell) -> String {
        switch shell {
        case .bash:
            return self.renderBashCompletionScript(using: context)
        case .zsh:
            return self.renderZshCompletionScript(using: context)
        }
    }
}

extension Command {

    // See `AnyCommand`.
    public func renderCompletionFunctions(using context: CommandContext, shell: Shell) -> String {
        switch shell {
        case .bash:
            return self.renderBashCompletionFunction(using: context, signatureValues: Signature.reference.values)
        case .zsh:
            return self.renderZshCompletionFunction(using: context, signatureValues: Signature.reference.values)
        }
    }
}

extension CommandGroup {

    // See `AnyCommand`.
    public func renderCompletionFunctions(using context: CommandContext, shell: Shell) -> String {
        var functions: [String] = []
        switch shell {
        case .bash:
            functions.append(self.renderBashCompletionFunction(using: context, subcommands: self.commands))
        case .zsh:
            functions.append(self.renderZshCompletionFunction(using: context, subcommands: self.commands))
        }
        for (name, command) in self.commands.sorted(by: { $0.key < $1.key }) {
            var context = context
            context.input.executablePath.append(name)
            functions.append(command.renderCompletionFunctions(using: context, shell: shell))
        }
        return functions.joined(separator: "\n")
    }
}

extension AnyCommand {

    /// Returns the contents of a bash completion file for `self` and, recursively,
    /// all of its descendent subcommands.
    fileprivate func renderBashCompletionScript(using context: CommandContext) -> String {
        return """
        \(self.renderCompletionFunctions(using: context, shell: .bash))
        complete -F _\(context.input.executableName) \(context.input.executableName)

        """
    }

    /// Returns the bash completion function for `self`.
    fileprivate func renderBashCompletionFunction(
        using context: CommandContext,
        signatureValues: [AnySignatureValue] = [],
        subcommands: [String: AnyCommand] = [:]
    ) -> String {
        let commandDepth = context.input.executablePath.count
        let isRootCommand = commandDepth == 1
        let arguments = ([Flag.help] + signatureValues.sorted(by: { $0.name < $1.name })).map { $0.completionInfo }
        let subcommands = subcommands.sorted(by: { $0.key < $1.key })
        let wordList = arguments.flatMap { $0.label?.values ?? [] } + subcommands.map { $0.key }
        return """
        function \(context.input.completionFunctionName())() { \(
            isRootCommand ? """

            local cur prev
            cur="${COMP_WORDS[COMP_CWORD]}"
            prev="${COMP_WORDS[COMP_CWORD-1]}"
            COMPREPLY=()
        """ : ""
        )\( !arguments.isEmpty ? """

            if [[ $COMP_CWORD != \(commandDepth) ]]; then
                case $prev in
        \( arguments.map { argument in
            let label = argument.label?.values.joined(separator: "|") ?? "*"
            if let action = argument.action {
                if let expression = action[.bash] {
                    return """
                    \(label))
                        \(expression)
                        return
                        ;;
        """
                } else {
                    return """
                    \(label)) return ;;
        """
                }
            } else {
                return """
                    \(label)) ;;
        """
            }
        }.joined(separator: "\n"))
                esac
            fi
        """ : ""
        )\( !subcommands.isEmpty ? """

            if [[ $COMP_CWORD != \(commandDepth) ]]; then
                case ${COMP_WORDS[\(commandDepth)]} in
        \( subcommands.map { (name, _) in
            return """
                    \(name))
                        \(context.input.completionFunctionName(forSubcommand: name)) \(commandDepth + 1)
                        return
                        ;;
        """
        }.joined(separator: "\n"))
                esac
            fi
        """ : ""
        )\( arguments.isEmpty && subcommands.isEmpty ? """

            :
        """ : ""
        )\( !wordList.isEmpty ? """

            COMPREPLY=( $(compgen -W "\(wordList.joined(separator: " "))" -- $cur) )
        """: ""
        )
        }

        """
    }

    /// Returns the contents of a zsh completion file for `self` and, recursively,
    /// all of its descendent subcommands.
    fileprivate func renderZshCompletionScript(using context: CommandContext) -> String {
        return """
        #compdef \(context.input.executableName)

        local context state state_descr line
        typeset -A opt_args

        \(self.renderCompletionFunctions(using: context, shell: .zsh))
        _\(context.input.executableName)

        """
    }

    /// Returns the zsh completion function for `self`.
    ///
    /// - Parameters:
    ///   - context: The command context to use to generate the function name.
    ///   - signatureValues: The signature values to use to generate the argument completions.
    ///   - subcommands: The subcommands to use to generate the subcommand completions.
    ///
    fileprivate func renderZshCompletionFunction(
        using context: CommandContext,
        signatureValues: [AnySignatureValue] = [],
        subcommands: [String: AnyCommand] = [:]
    ) -> String {
        let arguments = ([Flag.help] + signatureValues.sorted(by: { $0.name < $1.name })).map { $0.completionInfo }
        let subcommands = subcommands.sorted(by: { $0.key < $1.key })
        return """
        \(context.input.completionFunctionName())() {
            arguments=(
        \(arguments.map { argument in
            let help = argument.help.completionEscaped
            let action = argument.action.map { ": :\($0[.zsh] ?? " ")" } ?? ""
            if let long = argument.label?.long {
                return """
                "\((argument.label?.short).map { "(\(long) \($0))\"{\(long),\($0)}\"" } ?? long)[\(help)]\(action)"
        """
            } else {
                return """
                ":\(help): "
        """
            }
        }.joined(separator: "\n"))\(!subcommands.isEmpty ? """

                '(-): :->command'
                '(-)*:: :->arg'
        """ : "")
            )
            _arguments -C $arguments && return\(!subcommands.isEmpty ? """

            case $state in
                command)
                    local subcommands
                    subcommands=(
        \(subcommands.map { (name, command) in
            return """
                        "\(name):\(command.help.completionEscaped)"
        """
        }.joined(separator: "\n"))
                    )
                    _describe "subcommand" subcommands
                    ;;
                arg)
                    case ${words[1]} in
        \(subcommands.map { (name, _) in
            return """
                        \(name)) \(context.input.completionFunctionName(forSubcommand: name)) ;;
        """
        }.joined(separator: "\n"))
                    esac
                    ;;
            esac
        """ : ""
        )
        }

        """
    }
}

/// An action to be used in the shell completion script(s) to provide
/// special shell completion behaviors for an `Option` or `Argument`'s value.
public struct CompletionAction {

    /// The shell-specific implementations of the action.
    public var expressions: [Shell: String]

    public init(_ expressions: [Shell: String] = [:]) {
        self.expressions = expressions
    }

    public subscript(shell: Shell) -> String? {
        get { self.expressions[shell] }
        set { self.expressions[shell] = newValue }
    }
}

extension CompletionAction: ExpressibleByDictionaryLiteral {

    // See `ExpressibleByDictionaryLiteral`.
    public init(dictionaryLiteral elements: (Shell, String)...) {
        self.init([Shell: String](uniqueKeysWithValues: elements))
    }
}

extension CompletionAction {

    /// The empty `CompletionAction`, which represents a no-op.
    public static var `default`: CompletionAction { [:] }

    /// Creates a `CompletionAction` that will match against files with one of
    /// the given extensions.
    ///
    /// - Parameters:
    ///   - extensions: The file extensions to match against. If none are provided,
    ///   any file will match.
    ///
    public static func files(withExtensions extensions: [String] = []) -> CompletionAction {
        switch extensions.count {
        case 0:
            return [
                .bash: "_filedir",
                .zsh: "_files"
            ]
        case 1:
            return [
                .bash: "_filedir @(\(extensions[0]))",
                .zsh: "_files -g '*.\(extensions[0])'"
            ]
        default:
            return [
                .bash: "_filedir @(\(extensions.joined(separator: "|")))",
                .zsh: "_files -g '*.(\(extensions.joined(separator: "|")))'"
            ]
        }
    }

    /// Creates a `CompletionAction` that matches against files using an arbitrary
    /// globbing pattern.
    public static func files(matchingPattern pattern: String) -> CompletionAction {
        return [
            .bash: "_filedir",
            .zsh: "_files -g '\(pattern)'"
        ]
    }

    public static func directories(matchingPattern pattern: String? = nil) -> CompletionAction {
        return [
            .bash: "_filedir -d",
            .zsh: "_files -/\(pattern.map { " -g '\($0)'" } ?? "")"
        ]
    }

    public static func values(_ values: [String]) -> CompletionAction {
        return [
            .bash: "COMPREPLY=( $(compgen -W \"\(values.joined(separator: " "))\" -- $cur) )",
            .zsh: "{_values '' \(values.map { "'\($0)'" }.joined(separator: " "))}"
        ]
    }

    public static func values<C: CaseIterable & LosslessStringConvertible>(of type: C.Type) -> CompletionAction {
        return .values(C.allCases.map { "\($0)" })
    }
}

struct CompletionArgumentInfo {

    var name: String
    var help: String

    struct Label {

        var long: String
        var short: String?

        init(name: String, short: Character?) {
            self.long = "--\(name)"
            self.short = short.map { "-\($0)" }
        }

        var values: [String] {
            return [self.long] + (self.short.map { [$0] } ?? [])
        }
    }

    var label: Label?

    var action: CompletionAction?
}

extension Flag {

    /// A generic `--help` flag added to every command's completion.
    fileprivate static var help: Flag {
        return Flag(name: "help", short: "h", help: "Show more information about this command")
    }

    var completionInfo: CompletionArgumentInfo {
        return .init(
            name: self.name,
            help: self.help,
            label: .init(name: self.name, short: self.short)
        )
    }
}

extension Option {

    var completionInfo: CompletionArgumentInfo {
        return .init(
            name: self.name,
            help: self.help,
            label: .init(name: self.name, short: self.short),
            action: self.completionAction
        )
    }
}

extension Argument {

    var completionInfo: CompletionArgumentInfo {
        return .init(
            name: self.name,
            help: self.help,
            label: nil,
            action: self.completionAction
        )
    }
}

extension CommandInput {

    /// Returns the filename of the executable.
    ///
    /// For example, if the executable named `program` is run from the package's root
    /// via `swift run program`, the first element in `executablePath` will be something
    /// like `".build/x86_64-apple-macosx/debug/program"`; `executableName` will return
    /// `"program"`.
    ///
    fileprivate var executableName: String {
        return String(self.executablePath.first!.split(separator: "/").last!)
    }

    /// Returns the name to use for the completion function for the current `executablePath`.
    ///
    /// - Parameter subcommand: An optional subcommand name to append to the `executablePath`.
    ///
    /// For example, if the current `executablePath` is
    ///
    ///     [".build/x86_64-apple-macosx/debug/program", "subcommand1", "subcommand2"]
    ///
    /// the function name returned is `_program_subcommand1_subcommand2`.
    ///
    fileprivate func completionFunctionName(forSubcommand subcommand: String? = nil) -> String {
        var components: [String] = [self.executableName]
        if self.executablePath.count > 1 {
            components.append(contentsOf: self.executablePath[1...])
        }
        if let subcommand = subcommand {
            components.append(subcommand)
        }
        return "_" + components.joined(separator: "_")
    }
}

extension StringProtocol {

    /// Returns a copy of `self` with any characters that might cause trouble
    /// in a completion script escaped.
    fileprivate var completionEscaped: String {
        return self
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "(", with: "\\(")
            .replacingOccurrences(of: ")", with: "\\)")
            .replacingOccurrences(of: "{", with: "\\{")
            .replacingOccurrences(of: "}", with: "\\}")
            .replacingOccurrences(of: "[", with: "\\[")
            .replacingOccurrences(of: "]", with: "\\]")
            .replacingOccurrences(of: "\n", with: "\\n")
    }
}

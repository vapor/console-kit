/// Shell completion implementations.
public enum Shell {
    case bash
    case zsh
}

extension AnyCommand {

    /// Returns the complete contents of a completion file appropriate for the given
    /// `shell` for `self` and, recursively, al of its descendent subcommands.
    public func renderCompletionFile(using context: CommandContext, shell: Shell) -> String {
        switch shell {
        case .bash:
            return self.renderBashCompletionFile(using: context)
        case .zsh:
            return self.renderZshCompletionFile(using: context)
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

    fileprivate func renderBashCompletionFile(using context: CommandContext) -> String {
        return """
        \(self.renderCompletionFunctions(using: context, shell: .bash))
        complete -F _\(context.input.executableName) \(context.input.executableName)

        """
    }

    fileprivate func renderBashCompletionFunction(
        using context: CommandContext,
        signatureValues: [AnySignatureValue] = [],
        subcommands: [String: AnyCommand] = [:]
    ) -> String {
        let commandDepth = context.input.executablePath.count
        let isRootCommand = commandDepth == 1
        let signatureValues = signatureValues.sorted(by: { $0.name < $1.name })
        let subcommands = subcommands.sorted(by: { $0.key < $1.key })
        let wordList = signatureValues.flatMap { $0.labels } + subcommands.map { $0.key }
        return """
        function \(context.input.completionFunctionName())() { \(
            isRootCommand ? """

            local cur prev
            cur="${COMP_WORDS[COMP_CWORD]}"
            prev="${COMP_WORDS[COMP_CWORD-1]}"
            COMPREPLY=()
        """ : ""
        )\( !wordList.isEmpty ? """

            if [[ $COMP_CWORD == \(commandDepth) ]]; then
                COMPREPLY=( $(compgen -W "\(wordList.joined(separator: " "))" -- $cur) )
                return
            fi
        """ : ""
        )\( !signatureValues.isEmpty ? """

            case $prev in
        \( signatureValues.map { value in
            return """
                \(value.completionExpression(for: .bash))
        """
        }.joined(separator: "\n"))
            esac
        """ : ""
        )\( !subcommands.isEmpty ? """

            case ${COMP_WORDS[\(commandDepth)]} in
        \( subcommands.map { (name, _) in
            return """
                \(name)) \(context.input.completionFunctionName(forSubcommand: name)) \(commandDepth + 1) ;;
        """
        }.joined(separator: "\n"))
            esac
        """ : ""
        )\( signatureValues.isEmpty && subcommands.isEmpty ? """

            :
        """ : ""
        )
        }

        """
    }

    /// Returns the contents of a zsh completion file for `self` and, recursively,
    /// all of its descendent subcommands.
    fileprivate func renderZshCompletionFile(using context: CommandContext) -> String {
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
        let signatureValues = signatureValues.sorted(by: { $0.name < $1.name })
        let subcommands = subcommands.sorted(by: { $0.key < $1.key })
        return """
        \(context.input.completionFunctionName())() {
            arguments=(
        \(([Flag.help] + signatureValues).map {
            return """
                \($0.completionExpression(for: .zsh))
        """
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

extension Flag {

    /// A generic `--help` flag added to every command's completion.
    fileprivate static var help: Flag {
        return Flag(name: "help", short: "h", help: "Show more information about this command")
    }

    // See `AnySignatureValue`.
    func completionExpression(for shell: Shell) -> String {
        switch shell {
        case .bash:
            return "\(self.labels.joined(separator: "|"))) return ;;"
        case .zsh:
            let long = "--\(self.name)"
            let help = self.help.completionEscaped
            if let short = self.short.map({ "-\($0)" }) {
                return "\"(\(long) \(short))\"{\(long),\(short)}\"[\(help)]\""
            } else {
                return "\"\(long)[\(help)]\""
            }
        }
    }
}

extension Option {

    // See `AnySignatureValue`.
    func completionExpression(for shell: Shell) -> String {
        switch shell {
        case .bash:
            return "\(self.labels.joined(separator: "|"))) return ;;"
        case .zsh:
            let long = "--\(self.name)"
            let help = self.help.completionEscaped
            if let short = self.short.map({ "-\($0)" }) {
                return "\"(\(long) \(short))\"{\(long),\(short)}\"[\(help)]: : \""
            } else {
                return "\"\(long)[\(help)]: : \""
            }
        }
    }
}

extension Argument {

    // See `AnySignatureValue`.
    func completionExpression(for shell: Shell) -> String {
        switch shell {
        case .bash:
            return "*) return ;;"
        case .zsh:
            return "\":\(self.help.completionEscaped): \""
        }
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

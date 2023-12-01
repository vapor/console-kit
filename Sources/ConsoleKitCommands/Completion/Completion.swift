/// Shell completion implementations.
public enum Shell: String, LosslessStringConvertible, CaseIterable, Sendable {
    case bash
    case zsh

    // See `CustomStringConvertible`.
    public var description: String { self.rawValue }

    // See `LosslessStringConvertible`.
    public init?(_ description: String) {
        self.init(rawValue: description)
    }
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

extension AnyAsyncCommand {

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
            return self.renderBashCompletionFunction(using: context, signatureValues: Signature().values)
        case .zsh:
            return self.renderZshCompletionFunction(using: context, signatureValues: Signature().values)
        }
    }
}

extension AsyncCommand {

    // See `AnyAsyncCommand`.
    public func renderCompletionFunctions(using context: CommandContext, shell: Shell) -> String {
        switch shell {
        case .bash:
            return self.renderBashCompletionFunction(using: context, signatureValues: Signature().values)
        case .zsh:
            return self.renderZshCompletionFunction(using: context, signatureValues: Signature().values)
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

extension AsyncCommandGroup {

    // See `AnyAsyncCommand`.
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
        signatureValues: [any AnySignatureValue] = [],
        subcommands: [String: any AnyCommand] = [:]
    ) -> String {
        let commandDepth = context.input.executablePath.count
        let isRootCommand = commandDepth == 1
        let arguments = ([Flag.help] + signatureValues.sorted(by: { $0.name < $1.name })).map { $0.completionInfo }
        let subcommands = subcommands.sorted(by: { $0.key < $1.key })
        let wordList = arguments.flatMap { $0.labels?.values ?? [] } + subcommands.map { $0.key }
        return """
        function \(context.input.completionFunctionName())() { \(
            isRootCommand ? """

            local cur prev
            cur="${COMP_WORDS[COMP_CWORD]}"
            prev="${COMP_WORDS[COMP_CWORD-1]}"
            COMPREPLY=()
        """ : ""
        )\( !arguments.isEmpty ? """

            if [[ "$COMP_CWORD" -ne \(commandDepth) ]]; then
                case $prev in
        \( arguments.compactMap { argument in
            guard let label = argument.labels?.values.joined(separator: "|") else { return nil }
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

            if [[ "$COMP_CWORD" -ne \(commandDepth) ]]; then
                case ${COMP_WORDS[\(commandDepth)]} in
        \( subcommands.map { (name, _) in
            return """
                    \(name))
                        \(context.input.completionFunctionName(forSubcommand: name))
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

            COMPREPLY=( $(compgen -W "\(wordList.joined(separator: " "))" -- "$cur") )
        """: ""
        )\( arguments
            .filter { $0.labels == nil }
            .compactMap { $0.action?[.bash] }
            .map { "\n    \($0)" }
            .joined()
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
        signatureValues: [any AnySignatureValue] = [],
        subcommands: [String: any AnyCommand] = [:]
    ) -> String {
        let arguments = ([Flag.help] + signatureValues.sorted(by: { $0.name < $1.name })).map { $0.completionInfo }
        let subcommands = subcommands.sorted(by: { $0.key < $1.key })
        return """
        \(context.input.completionFunctionName())() {
            arguments=(
        \(arguments.map { argument in
            let help = argument.help.completionEscaped
            if let long = argument.labels?.long {
                let labels = (argument.labels?.short).map { "(\(long) \($0))\"{\(long),\($0)}\"" } ?? long
                let action = argument.action.map { ": :\($0[.zsh] ?? " ")" } ?? ""
                return """
                "\(labels)[\(help)]\(action)"
        """
            } else {
                return """
                ":\(help):\(argument.action?[.zsh] ?? " ")"
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

extension AnyAsyncCommand {

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
        signatureValues: [any AnySignatureValue] = [],
        subcommands: [String: any AnyAsyncCommand] = [:]
    ) -> String {
        let commandDepth = context.input.executablePath.count
        let isRootCommand = commandDepth == 1
        let arguments = ([Flag.help] + signatureValues.sorted(by: { $0.name < $1.name })).map { $0.completionInfo }
        let subcommands = subcommands.sorted(by: { $0.key < $1.key })
        let wordList = arguments.flatMap { $0.labels?.values ?? [] } + subcommands.map { $0.key }
        return """
        function \(context.input.completionFunctionName())() { \(
            isRootCommand ? """

            local cur prev
            cur="${COMP_WORDS[COMP_CWORD]}"
            prev="${COMP_WORDS[COMP_CWORD-1]}"
            COMPREPLY=()
        """ : ""
        )\( !arguments.isEmpty ? """

            if [[ "$COMP_CWORD" -ne \(commandDepth) ]]; then
                case $prev in
        \( arguments.compactMap { argument in
            guard let label = argument.labels?.values.joined(separator: "|") else { return nil }
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

            if [[ "$COMP_CWORD" -ne \(commandDepth) ]]; then
                case ${COMP_WORDS[\(commandDepth)]} in
        \( subcommands.map { (name, _) in
            return """
                    \(name))
                        \(context.input.completionFunctionName(forSubcommand: name))
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

            COMPREPLY=( $(compgen -W "\(wordList.joined(separator: " "))" -- "$cur") )
        """: ""
        )\( arguments
            .filter { $0.labels == nil }
            .compactMap { $0.action?[.bash] }
            .map { "\n    \($0)" }
            .joined()
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
        signatureValues: [any AnySignatureValue] = [],
        subcommands: [String: any AnyAsyncCommand] = [:]
    ) -> String {
        let arguments = ([Flag.help] + signatureValues.sorted(by: { $0.name < $1.name })).map { $0.completionInfo }
        let subcommands = subcommands.sorted(by: { $0.key < $1.key })
        return """
        \(context.input.completionFunctionName())() {
            arguments=(
        \(arguments.map { argument in
            let help = argument.help.completionEscaped
            if let long = argument.labels?.long {
                let labels = (argument.labels?.short).map { "(\(long) \($0))\"{\(long),\($0)}\"" } ?? long
                let action = argument.action.map { ": :\($0[.zsh] ?? " ")" } ?? ""
                return """
                "\(labels)[\(help)]\(action)"
        """
            } else {
                return """
                ":\(help):\(argument.action?[.zsh] ?? " ")"
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
/// special shell completion behaviors for an `Option`'s argument or a
/// positional `Argument`.
public struct CompletionAction: Sendable {

    /// The shell-specific implementations of the action.
    public let expressions: [Shell: String]

    public init(_ expressions: [Shell: String] = [:]) {
        self.expressions = expressions
    }

    public subscript(shell: Shell) -> String? {
        self.expressions[shell]
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

    /// Creates a `CompletionAction` that uses a built-in function to generate file matches.
    ///
    /// - Parameters:
    ///   - extensions: The file extensions to match against. If none are provided,
    ///   any file will match.
    ///
    public static func files(withExtensions extensions: [String] = []) -> CompletionAction {
        switch extensions.count {
        case 0:
            return [
                .bash: #"if declare -F _filedir >/dev/null; then _filedir; else COMPREPLY+=( $(compgen -f -- "$cur") ); fi"#,
                .zsh: "_files"
            ]
        default:
            return [
                .bash: #"if declare -F _filedir >/dev/null; "# +
                       #"then _filedir '@(\#(extensions.joined(separator: "|")))'; "# +
                       #"else COMPREPLY+=( \#(extensions.map { #"$(compgen -f -X '!*.\#($0)' -- "$cur")"# }.joined(separator: "; ")) ); "# +
                       #"fi"#,
                .zsh: "_files -g '*.(\(extensions.joined(separator: "|")))'"
            ]
        }
    }

    /// Creates a `CompletionAction` that uses a built-in function to generate directory matches.
    public static func directories() -> CompletionAction {
        [
            .bash: #"if declare -F _filedir >/dev/null; then _filedir -d; else COMPREPLY+=( compgen -d -- "$cur" ); fi"#,
            .zsh: "_files -/"
        ]
    }

    /// Creates a `CompletionAction` that provides a predefined list of possible values.
    public static func values(_ values: [String]) -> CompletionAction {
        return [
            .bash: #"COMPREPLY+=( $(compgen -W "\#(values.joined(separator: " "))" -- "$cur") )"#,
            .zsh: "{_values '' \(values.map { "'\($0)'" }.joined(separator: " "))}"
        ]
    }

    /// Creates a `CompletionAction` that provides a predefined list of possible values
    /// generated from a `CaseIterable` type.
    public static func values<C: CaseIterable & LosslessStringConvertible>(of type: C.Type) -> CompletionAction {
        return .values(C.allCases.map { "\($0)" })
    }
}

/// Type-erased information for a command signature value (e.g. `Flag`, `Option`, `Argument`),
/// and its argument.
struct CompletionSignatureValueInfo {

    /// The possible labels for a command signature value, consisting of a long (`--long`) form
    /// and an optional short (`-l`) form.
    struct Labels {

        /// The long form of the label (including its leading dashes).
        var long: String

        /// The optional short form of the label (including its leading dash).
        var short: String?

        /// Creates a `Label` from an `AnySignatureValue`'s `name` and `short` properties.
        init(name: String, short: Character?) {
            self.long = "--\(name)"
            self.short = short.map { "-\($0)" }
        }

        /// Returns an array containing the label's non-nil string values.
        var values: [String] {
            return [self.long] + (self.short.map { [$0] } ?? [])
        }
    }

    /// The name of the command signature value (without any leading dashes).
    var name: String

    /// The help text for the command signature value.
    var help: String

    /// The labels for the command signature value.
    ///
    /// `Argument`s do not have `labels`; `Flag`s and `Option`s do.
    ///
    var labels: Labels?

    /// The completion action for the command signature value's argument.
    ///
    /// `Flag`s do not have an argument, and thus do not have an `action`; `Option`s
    /// and `Argument`s do.
    ///
    var action: CompletionAction?
}

extension Flag {

    /// A generic `--help` flag added to every command's completion.
    fileprivate static var help: Flag {
        return Flag(name: "help", short: "h", help: "Show more information about this command")
    }

    // See `AnySignatureValue`.
    var completionInfo: CompletionSignatureValueInfo {
        return .init(
            name: self.name,
            help: self.help,
            labels: .init(name: self.name, short: self.short)
        )
    }
}

extension Option {

    // See `AnySignatureValue`.
    var completionInfo: CompletionSignatureValueInfo {
        return .init(
            name: self.name,
            help: self.help,
            labels: .init(name: self.name, short: self.short),
            action: self.completion
        )
    }
}

extension Argument {

    // See `AnySignatureValue`.
    var completionInfo: CompletionSignatureValueInfo {
        .init(
            name: self.name,
            help: self.help,
            action: self.completion
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
    var executableName: String {
        String(self.executablePath.first!.split(separator: "/").last!)
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
        self
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "(", with: "\\(")
            .replacingOccurrences(of: ")", with: "\\)")
            .replacingOccurrences(of: "{", with: "\\{")
            .replacingOccurrences(of: "}", with: "\\}")
            .replacingOccurrences(of: "[", with: "\\[")
            .replacingOccurrences(of: "]", with: "\\]")
            .replacingOccurrences(of: "\n", with: " ")
    }
}

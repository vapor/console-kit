extension Command {
    public func printUsage(executable: String) {
        console.info("Usage: ", newLine: false)
        console.print("\(executable) \(id) ", newLine: false)

        var signatureLine: [String] = []

        for value in signature.values {
            signatureLine.append("<\(value.name)>")
        }

        for option in signature.options {
            signatureLine.append("[--\(option.name)]")
        }

        console.print(signatureLine.joined(separator: " "))
    }

    public func printSignatureHelp() {
        var namePadding = 0
        for argument in signature {
            let count = argument.name.characters.count

            if count > namePadding {
                namePadding = count
            }
        }

        for argument in signature {
            let padding = ""
            console.print(padding, newLine: false)

            for _ in 0 ..< (namePadding - argument.name.characters.count) {
                console.print(" ", newLine: false)
            }

            console.print(argument.name, newLine: false)
            console.print(": ", newLine: false)

            for (i, help) in argument.help.enumerated() {
                if i != 0 {
                    console.print(padding, newLine: false)
                    for _ in 0 ..< namePadding {
                        console.print(" ", newLine: false)
                    }
                    console.print("  ", newLine: false)
                }
                
                console.print(help)
            }
        }
        
    }
}

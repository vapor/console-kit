extension Command {
    public func printUsage(executable: String) {
        console.info("Usage: ", newLine: false)
        console.print("\(executable) \(id) ", newLine: false)

        for value in signature.values {
            console.warning("<\(value.name)> ", newLine: false)
        }

        for option in signature.options {
            let short = option.short != nil ? " -\(option.short!)" : ""
            console.success("[--\(option.name)\(short)] ", newLine: false)
        }
        print("")
    }

    public func printSignatureHelp() {
        var maxWidth = 0
        for runnable in signature {
            let count = runnable.name.characters.count
            if count > maxWidth {
                maxWidth = count
            }
        }
        
        let leadingSpace = 2
        let width = maxWidth + leadingSpace
        
        let vals = signature.flatMap { $0 as? Value }
        let opts = signature.flatMap { $0 as? Option }
        
        console.info("Arugments:")
        for val in vals {
            console.print(String(
                repeating: " ", count: width - val.name.characters.count),
                newLine: false
            )
            console.warning(val.name, newLine: false)
            
            for (i, help) in val.help.enumerated() {
                console.print(" ", newLine: false)
                if i != 0 {
                    console.print(String(
                        repeating: " ", count: width),
                        newLine: false
                    )
                }
                console.print(help)
            }
        }
        print("")
        
        console.info("Options:")
        for opt in opts {
            console.print(String(
                repeating: " ", count: width - opt.name.characters.count),
                newLine: false
            )
            console.success(opt.name, newLine: false)
            
            for (i, help) in opt.help.enumerated() {
                console.print(" ", newLine: false)
                if i != 0 {
                    console.print(String(
                        repeating: " ", count: width),
                        newLine: false
                    )
                }
                console.print(help)
            }

        }
    }
}

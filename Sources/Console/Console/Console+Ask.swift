extension ConsoleProtocol {
    /**
        Requests input from the console
        after displaying the desired prompt.
    */
    public func ask(_ prompt: String, style: ConsoleStyle = .info) -> String {
        output(prompt, style: style)
        output("> ", style: style, newLine: false)
        return input()
    }
}
extension ConsoleProtocol {
    public func askList(withTitle title: String, from list: [String]) -> String? {
        info(title)
        list.enumerated().forEach { idx, item in
            // offset 0 to start at 1
            let offset = idx + 1
            info("\(offset): ", newLine: false)
            print(item)
        }
        output("> ", style: .plain, newLine: false)
        let raw = input()
        guard let idx = Int(raw) else {
            // .count is implicitly offset, no need to adjust
            warning("Invalid selection '\(raw)', expected: 1...\(list.count)")
            return nil
        }
        // undo previous offset back to 0 indexing
        let offset = idx - 1
        guard offset < list.count else { return nil }
        return list[offset]
    }
}

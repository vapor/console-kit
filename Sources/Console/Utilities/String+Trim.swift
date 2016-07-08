extension String {
    public func trim(characters: [Character] = [" ", "\t", "\n"]) -> String {
        // while characters
        var mutable = self
        while let next = mutable.characters.first where characters.contains(next) {
            mutable.remove(at: mutable.startIndex)
        }
        while let next = mutable.characters.last where characters.contains(next) {
            mutable.remove(at: mutable.index(before: mutable.endIndex))
        }
        return mutable
    }
}

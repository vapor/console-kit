extension String {
    public func trim(characters: [Character] = [" ", "\t", "\n", "\r"]) -> String {
        // while characters
        var mutable = self
        while let next = mutable.first, characters.contains(next) {
            mutable.remove(at: mutable.startIndex)
        }
        while let next = mutable.last, characters.contains(next) {
            mutable.remove(at: mutable.index(before: mutable.endIndex))
        }
        return mutable
    }
}

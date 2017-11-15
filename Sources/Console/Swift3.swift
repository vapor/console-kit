#if swift(>=4)
#else
    extension String {
        internal var count: Int {
            return characters.count
        }

        internal subscript(_ index: Int) -> Character {
            get { return characters[index] }
        }

        // index(message.characters.startIndex, offsetBy: j)
        internal func index(_ start: Int, offsetBy offset: Int) -> Range {
            return characters.index(start, offsetBy: offset)
        }

        internal var startIndex: Int {
            return characters.startIndex
        }

        internal var first: Character? {
            return characters.first
        }

        internal var last: Character? {
            return characters.last
        }
    }
#endif

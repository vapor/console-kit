#if swift(>=4)
#else
    extension String {
        internal var count: Int {
            return characters.count
        }

        internal subscript(_ index: String.CharacterView.Index) -> Character {
            get { return characters[index] }
        }

        // index(message.characters.startIndex, offsetBy: j)
        internal func index(
            _ start: String.CharacterView.Index, 
            offsetBy offset: String.CharacterView.IndexDistance
        ) -> String.CharacterView.Index {
            return characters.index(start, offsetBy: offset)
        }

        internal var startIndex: String.CharacterView.Index {
            return characters.startIndex
        }

        internal var first: Character? {
            return characters.first
        }

        internal var last: Character? {
            return characters.last
        }

        // element.split(separator: "-", maxSplits: 2, omittingEmptySubsequences: false)
        internal func split(separator: Character, maxSplits: Int, omittingEmptySubsequences: Bool) -> [String.CharacterView.SubSequence] {
            return characters.split(separator: separator, maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences)
        }
    }
#endif

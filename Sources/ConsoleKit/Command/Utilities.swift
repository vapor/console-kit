extension Array {
    /// Pops the first element from the array.
    mutating func popFirst() -> Element? {
        guard let pop = first else {
            return nil
        }
        self = Array(dropFirst())
        return pop
    }
}

extension Array where Element == String {
    var longestCount: Int {
        var count = 0

        for item in self {
            if item.count > count {
                count = item.count
            }
        }

        return count
    }
}

extension Console {
    func outputHelpListItem(name: String, help: String?, style: ConsoleStyle, padding: Int) {
        self.output(name.leftPad(to: padding - name.count).consoleText(style), newLine: false)
        if let help = help {
            for (index, line) in help.split(separator: "\n").map(String.init).enumerated() {
                if index == 0 {
                    self.print(line.leftPad(to: 1))
                } else {
                    self.print(line.leftPad(to: padding + 1))
                }
            }
        } else {
            self.print(" n/a")
        }
    }
}


private extension String {
    func leftPad(to padding: Int) -> String {
        return String(repeating: " ", count: padding) + self
    }
}

extension String {
    /// Calculate the Levenshtein distance to another
    /// - Parameter target: Another String
    /// - See: https://en.wikipedia.org/wiki/Levenshtein_distance
    func levenshteinDistance(to target: String) -> Int {
        guard self != target else { return 0 }
        
        // Short-circuit trivial cases
        if self.isEmpty {
            return target.count
        }
        
        if target.isEmpty {
            return self.count
        }
        
        // create two work vectors of integer distances
        var v0: [Int] = Array(repeating: 0, count: target.count + 1)
        var v1: [Int] = Array(repeating: 0, count: target.count + 1)
        
        // initialize v0 (the previous row of distances)
        // this row is A[0][i]: edit distance for an empty s
        // the distance is just the number of characters to delete from t
        for i in 0..<v0.count {
            v0[i] = i
        }
        
        for i in 0..<self.count {
            // calculate v1 (current row distances) from the previous row v0

            // first element of v1 is A[i+1][0]
            //   edit distance is delete (i+1) chars from s to match empty t
            v1[0] = i + 1
            
            // use formula to fill in the rest of the row
            for j in 0..<target.count {
                // calculating costs for A[i+1][j+1]
                let deletionCost = v0[j + 1] + 1
                let insertionCost = v1[j] + 1
                let sourceIndex = self.index(self.startIndex, offsetBy: i)
                let targetIndex = target.index(target.startIndex, offsetBy: j)
                let substitutionCost = self[sourceIndex] == target[targetIndex] ? v0[j] : v0[j] + 1

                v1[j + 1] = [deletionCost, insertionCost, substitutionCost].min()!
            }
            
            // copy v1 (current row) to v0 (previous row) for next iteration
            for j in 0..<v0.count {
                v0[j] = v1[j]
            }
        }
        
        return v0[target.count]
    }
}

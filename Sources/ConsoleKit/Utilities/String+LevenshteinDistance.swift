import Foundation

extension String {
    /// Calculate the Levenshtein distance to another String
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
        
        // Create two work vectors of integer distances
        var v0: [Int] = Array(repeating: 0, count: target.count + 1)
        var v1: [Int] = Array(repeating: 0, count: target.count + 1)
        
        // Initialize v0 (the previous row of distances)
        // This row is A[0][i]: edit distance for an empty s
        // The distance is just the number of characters to delete from t
        for i in 0..<v0.count {
            v0[i] = i
        }
        
        for i in 0..<self.count {
            // Calculate v1 (current row distances) from the previous row v0

            // First element of v1 is A[i+1][0]
            // Edit distance is delete (i+1) chars from s to match empty t
            v1[0] = i + 1
            
            // Use formula to fill in the rest of the row
            for j in 0..<target.count {
                // Calculating costs for A[i+1][j+1]
                let deletionCost = v0[j + 1] + 1
                let insertionCost = v1[j] + 1
                let sourceIndex = self.index(self.startIndex, offsetBy: i)
                let targetIndex = target.index(target.startIndex, offsetBy: j)
                let substitutionCost = self[sourceIndex] == target[targetIndex] ? v0[j] : v0[j] + 1

                v1[j + 1] = [deletionCost, insertionCost, substitutionCost].min()!
            }
            
            // Copy v1 (current row) to v0 (previous row) for next iteration
            for j in 0..<v0.count {
                v0[j] = v1[j]
            }
        }
        // After the last swap, the results of v1 are now in v0
        return v0[target.count]
    }
}

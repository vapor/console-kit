import Foundation

extension Sequence where Iterator.Element == String {
    public var options: [String: String] {
        let longs = self.filter({ $0.hasPrefix("--") })
        let shorts = self.filter({ !$0.hasPrefix("--") }).filter({ $0.hasPrefix("-") })
        var options: [String: String] = [:]
        
        longs.forEach { (element) in
            let parts = element.split(separator: "-", maxSplits: 2, omittingEmptySubsequences: false)
            
            guard parts.count == 3 else {
                return
            }
            
            let token = parts[2].split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            
            let name = String(token[0])
            
            if token.count == 2 {
                options[name] = String(token[1])
            } else {
                options[name] = "true"
            }
        }
        
        shorts.forEach { (element) in
            let parts = element.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false)
            
            guard parts.count == 2 else {
                return
            }
            
            let token = parts[1].split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            
            let name = String(token[0])
            
            if token.count == 2 {
                options[name] = String(token[1])
            } else {
                options[name] = "true"
            }
        }
        
        return options
    }

    public var values: [String] {
        return filter { !$0.hasPrefix("-") }
    }

    public func argument(_ name: String) throws -> String {
        return ""
    }

    public func option(_ name: String) -> String? {
        return options[name]
    }

    public func flag(_ name: String) -> Bool {
        return option(name)?.bool == true
    }
}

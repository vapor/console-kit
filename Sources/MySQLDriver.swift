import Fluent
import Foundation

public class MySQLDriver: Fluent.Driver {
    private(set) var database: MySQL!
    private init() { }  

    public init(username: String, password: String, host: String, database: String, port: UInt = 3306, flag: UInt = 0) throws {
        self.database = try MySQL(username: username, password: password, host: host, database: database, port: port, flag: flag)
    }
    
    public init(username: String, password: String, database: String, socket: String, flag: UInt = 0) throws {
        self.database = try MySQL(username: username, password: password, database: database, socket: socket, flag: flag)
    }
    
    public func execute<T : Model>(query: Query<T>) throws -> [[String : Value]] {
        let sql = SQL(query: query)
        let results: [[String: String]]
        let statement = sql.statement
        let values = sql.values
        
        do {
            if values.count > 0 {
                let escapedValues = try self.database.escapeValues(values)
                let newStatement = combine(statement, values: escapedValues)
                results = try self.database.execute(newStatement)
            } else {
                results = try self.database.execute(statement)
            }
        } catch {
            print(self.database.errorMessage)
            throw DriverError.Generic(message: self.database.errorMessage)
        }
        
        var data: [[String: Value]] = []
        
        for row in results {
            var t: [String: Value] = [:]
            for (k, v) in row {
                t[k] = v as String
            }
            data.append(t)
        }
        
        return data
    }
    
    func combine(query: String, values: [String]) -> String {
        var vals = values
        let splits = query.componentsSeparated(by: "?")
        var str = ""
        for comp in splits {
            str.append(comp)
            if vals.isEmpty {
                continue
            }
            str.append(vals.removeFirst())
        }
        
        
        return str
    }
}

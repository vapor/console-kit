import Fluent

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
        
        do {
            if sql.values.count > 0 {
                var position = 1
                results = try self.database.execute(sql.statement) {
                    for value in sql.values {
                        if let int = value.int {
                            self.database.bind(Int32(int), position: position)
                        } else if let double = value.double {
                            self.database.bind(double, position: position)
                        } else {
                            self.database.bind(value.string, position: position)
                        }
                        position += 1
                    }
                }
            } else {
                results = try self.database.execute(sql.statement)
            }
        } catch {
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
}

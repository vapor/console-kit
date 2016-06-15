import Fluent

public class MySQLDriver: Fluent.Driver {
    public var idKey: String = "id"
    public var database: MySQL

    public init(
        username: String,
        password: String,
        host: String,
        database: String,
        port: UInt32 = 3306,
        flag: UInt = 0
    ) throws {
        self.database = try MySQL(
            username: username,
            password: password,
            host: host,
            database: database,
            port: port,
            flag: flag
        )
    }
    
    public func execute<T : Model>(_ query: Query<T>) throws -> [[String: Value]] {
        let sql = SQL(query: query)
        let statement = sql.statement

        var results: [[String: Value]] = []

        for row in try database.execute(statement) {
            var result: [String: Value] = [:]

            for (key, val) in row {
                result[key] = val ?? StructuredData.null
            }

            results.append(result)
        }

        return results
    }
}

extension StructuredData: Value {
    public var structuredData: StructuredData {
        return self
    }
}

extension StructuredData: CustomStringConvertible {
    public var description: String {
        return "\(self)"
    }
}

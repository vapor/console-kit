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

    public init(_ database: MySQL) {
        self.database = database
    }

    @discardableResult
    public func execute<T : Model>(_ query: Query<T>) throws -> [[String: Value]] {
        let sql = SQL(query: query)
        let statement = sql.statement

        var results = try raw(statement, sql.values)

        if query.action == .create {
            if let insert = try raw("SELECT LAST_INSERT_ID() as id").first?["id"] {
                results.append([
                    "id": insert
                ])
            }
        }

        return results
    }

    @discardableResult
    public func raw(_ query: String, _ values: [Value] = []) throws -> [[String: Value]] {
        var results: [[String: Value]] = []

        let values = values.map { $0.mysql }

        for row in try database.execute(query, values) {
            var result: [String: Value] = [:]

            for (key, val) in row {
                result[key] = val
            }

            results.append(result)
        }

        return results
    }
}

extension Value {
    public var mysql: MySQL.Value {
        switch structuredData {
        case .int(let int):
            return .int(int)
        case .double(let double):
            return .double(double)
        case .string(let string):
            return .string(string)
        default:
            return .null
        }
    }
}

extension MySQL.Value: Value {
    public var structuredData: StructuredData {
        switch self {
        case .string(let string):
            return .string(string)
        case .int(let int):
            return .int(int)
        case .uint(let uint):
            return .int(Int(uint))
        case .double(let double):
            return .double(double)
        case .null:
            return .null
        }
    }

    public var description: String {
        switch self {
        case .string(let string):
            return string
        case int(let int):
            return "\(int)"
        case .uint(let uint):
            return "\(uint)"
        case .double(let double):
            return "\(double)"
        case .null:
            return "NULL"
        }
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

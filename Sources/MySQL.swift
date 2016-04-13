#if os(Linux)
    import CMySQLLinux
#else
    import CMySQLMac
#endif

public enum MySQLError: ErrorProtocol {
    case NoConnection, BadSQL, IndexOutOfBounds, UnableToBindResults, FailedToEscapeValue
}

public class MySQL {
    enum FieldType {
        case Null
        case Tiny
        case Short
        case Long
        case LongLong
        case Float
        case Double
        case String
        case Date
        case Data
    }
    
    public typealias BindHandler = (() throws -> ())
    private var mysql: UnsafeMutablePointer<MYSQL>!
    private var statement: UnsafeMutablePointer<MYSQL_STMT>!
    private var bindings: UnsafeMutablePointer<MYSQL_BIND>!
    private var columnsCount: Int {
        return Int(mysql_stmt_field_count(self.statement))
    }

    public var errorMessage: String {
        return "\(String(cString:mysql_error(mysql)))"
    }
    
    deinit {
        close()
    }
    
    public init(username: String, password: String, host: String, database: String, port: UInt = 3306, flag: UInt = 0) throws {
        if mysql == nil {
            mysql = mysql_init(nil)
        }
        
        let connection = mysql_real_connect(mysql, host, username, password, database, UInt32(port), nil, flag)
        if connection == nil {
            throw MySQLError.NoConnection
        }

    }
    
    public init(username: String, password: String, database: String, socket: String, flag: UInt = 0) throws {
        if mysql == nil {
            mysql = mysql_init(nil)
        }
        
        let connection = mysql_real_connect(mysql, nil, username, password, database, 0, socket, flag)
        if connection == nil {
            throw MySQLError.NoConnection
        }
    }
    
    public func close() {
        if let statement = self.statement {
            mysql_stmt_close(statement)
        }
        if let mysql = mysql {
            mysql_close(mysql)
        }
    }
    
    public func escapeValues(values: [String]) throws -> [String] {
        var escapedVals = [String]()
        for val in values {
            let escaped = UnsafeMutablePointer<Int8>(allocatingCapacity: 1)

            defer {
                escaped.deinitialize()
                escaped.deallocateCapacity(1)
            }

            let length = Int(mysql_real_escape_string(mysql, escaped, val, strlen(val)))
            escaped.advanced(by: length).initialize(with: 0)

            guard let escapedString = String(validatingUTF8: escaped) else {
                throw MySQLError.FailedToEscapeValue
            }
            escapedVals.append(escapedString)
        }
        return escapedVals
    }
    
    public func execute(query: String) throws -> [[String: String]] {
        guard mysql_query(mysql, query) == 0 else {
            throw MySQLError.BadSQL
        }
        
        let result = mysql_use_result(mysql)
        
        if mysql_errno(mysql) > 0 {
            throw MySQLError.BadSQL
        }
        
        if query.hasPrefix("UPDATE") || query.hasPrefix("DELETE") || query.hasPrefix("INSERT") {
            return []
        }
        
        var results = [[String: String]]()
        var row = mysql_fetch_row(result)
        repeat {
            for (index, columnField) in columns(result).enumerated() {
                results.append([columnField: String(cString: row[index])])
            }
            row = mysql_fetch_row(result)
        } while row != nil
        
        defer { mysql_free_result(result) }
        return results
    }
    
    func columns(result: UnsafeMutablePointer<MYSQL_RES>) -> [String] {
        var _columns = [String]()
        let columnsFields = mysql_fetch_fields(result)
        for i in 0..<Int(mysql_num_fields(result)) {
            _columns.append(String(cString:columnsFields[i].name))
        }
        return _columns
    }
}

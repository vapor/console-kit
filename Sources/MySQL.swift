#if os(Linux)
    import CMySQLLinux
#else
    import CMySQLMac
#endif

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


    public enum Error: ErrorProtocol {
        case connection(String)
        case query(String)
        case fieldFetch
        case escape
    }

    typealias Statement = UnsafeMutablePointer<MYSQL_STMT>
    typealias Connection = UnsafeMutablePointer<MYSQL>
    typealias Bindings = UnsafeMutablePointer<MYSQL_BIND>
    typealias Char = Int8

    struct Result {
        static let ok: Int32 = 0
    }
    
    public typealias BindHandler = (() throws -> ())

    let connection: Connection

    public init(
        username: String,
        password: String,
        host: String,
        database: String,
        port: UInt32 = 3306,
        socket: String? = nil,
        flag: UInt = 0
    ) throws {
        connection = mysql_init(nil)

        guard mysql_real_connect(connection, host, username, password, database, port, socket, flag) != nil else {
            throw Error.connection(errorMessage)
        }
    }

    @discardableResult
    public func execute(_ query: String, _ values: [String] = []) throws -> [[String: String?]] {
        let statement = mysql_stmt_init(connection)

        if values.count > 0 {
            var binds: [MYSQL_BIND] = []

            for value in values {
                /*
 MYSQL_TYPE_DECIMAL, MYSQL_TYPE_TINY,
 MYSQL_TYPE_SHORT,  MYSQL_TYPE_LONG,
 MYSQL_TYPE_FLOAT,  MYSQL_TYPE_DOUBLE,
 MYSQL_TYPE_NULL,   MYSQL_TYPE_TIMESTAMP,
 MYSQL_TYPE_LONGLONG,MYSQL_TYPE_INT24,
 MYSQL_TYPE_DATE,   MYSQL_TYPE_TIME,
 MYSQL_TYPE_DATETIME, MYSQL_TYPE_YEAR,
 MYSQL_TYPE_NEWDATE, MYSQL_TYPE_VARCHAR,*/
                let type = MYSQL_TYPE_DECIMAL
                let bind = MYSQL_BIND(length: nil, is_null: nil, buffer: nil, error: nil, row_ptr: nil, store_param_func: nil, fetch_result: nil, skip_result: nil, buffer_length: 5, offset: 0, length_value: 5, param_number: 0, pack_length: 0, buffer_type: type, error_value: 0, is_unsigned: 0, long_data_used: 0, is_null_value: 0, extension: nil)
                binds.append(bind)
            }

            mysql_stmt_bind_param(statement, &binds[0])
        }

        mysql_stmt_prepare(statement, query, strlen(query))



        /*guard mysql_query(connection, query) == Result.ok else {
            throw Error.query(errorMessage)
        }

        guard let resultPointer = mysql_use_result(connection) else {
            return []
        }

        guard let fieldsPointer = mysql_fetch_fields(resultPointer) else {
            throw Error.fieldFetch
        }

        var fields: [String] = []

        for i in 0 ..< Int(mysql_num_fields(resultPointer)) {
            let field = String(cString: fieldsPointer[i].name)
            fields.append(field)
        }*/

        let metadata = mysql_stmt_result_metadata(statement)

        guard let fields = mysql_fetch_fields(metadata) else {
            throw Error.fieldFetch
        }

        let fieldsCount = Int(mysql_num_fields(metadata))

        let resultBuffer = UnsafeMutablePointer<MYSQL_BIND>.init(allocatingCapacity: fieldsCount)
        defer {
            resultBuffer.deinitialize()
            resultBuffer.deallocateCapacity(1)
        }

        for i in 0 ..< fieldsCount {
            let field = fields[i]
            var bind = resultBuffer[i]
            bind.buffer_type = field.type

            switch field.type {
            case MYSQL_TYPE_TINY:
                print("TINYINT field")
            case MYSQL_TYPE_SHORT:
                print("SMALLINT field")
            case MYSQL_TYPE_LONG:
                print("INTEGER field")
            case MYSQL_TYPE_INT24:
                print("MEDIUMINT field")
            case MYSQL_TYPE_LONGLONG:
                print("BIGINT field")
            case MYSQL_TYPE_DECIMAL:
                print("DECIMAL or NUMERIC field")
            case MYSQL_TYPE_NEWDECIMAL:
                print("Precision math DECIMAL or NUMERIC")
            case MYSQL_TYPE_FLOAT:
                print("FLOAT field")
            case MYSQL_TYPE_DOUBLE:
                print("DOUBLE or REAL field")
            case MYSQL_TYPE_BIT:
                print("BIT field")
            case MYSQL_TYPE_TIMESTAMP:
                print("TIMESTAMP field")
            case MYSQL_TYPE_DATE:
                print("DATE field")
            case MYSQL_TYPE_TIME:
                print("TIME field")
            case MYSQL_TYPE_DATETIME:
                print("DATETIME field")
            case MYSQL_TYPE_YEAR:
                print("YEAR field")
            case MYSQL_TYPE_STRING:
                print("CHAR or BINARY field")
            case MYSQL_TYPE_VAR_STRING:
                print("VARCHAR or VARBINARY field")
            case MYSQL_TYPE_BLOB:
                print("BLOB or TEXT field (use max_length to determine the maximum length)")
            case MYSQL_TYPE_SET:
                print("SET field")
            case MYSQL_TYPE_ENUM:
                print("ENUM field")
            case MYSQL_TYPE_GEOMETRY:
                print("Spatial field")
            case MYSQL_TYPE_NULL:
                print("NULL-type field")
            default:
                print("unknown")
            }


            let length = Int(field.length) * sizeof(UInt8)

            bind.buffer_length = UInt(length)

            bind.buffer = UnsafeMutablePointer<Void>(allocatingCapacity: length)
            bind.length = UnsafeMutablePointer<UInt>(allocatingCapacity: 1)
            bind.is_null = UnsafeMutablePointer<my_bool>(allocatingCapacity: 1)
            bind.error = UnsafeMutablePointer<my_bool>(allocatingCapacity: 1)

            resultBuffer[i] = bind
        }

        mysql_stmt_bind_result(statement, resultBuffer)

        mysql_stmt_execute(statement)

        while mysql_stmt_fetch(statement) == Result.ok {
            print(resultBuffer[0].is_null.pointee)

            let buffer = resultBuffer[0].buffer

            let charBuffer = UnsafeMutablePointer<Int8>(buffer)
            let string = String(cString: charBuffer!)

            print(string)

            
            mysql_stmt_bind_result(statement, resultBuffer)
        }




        /*var results: [[String: String?]] = []

        while let row = mysql_fetch_row(resultPointer) {
            var parsed: [String: String?] = [:]

            for (i, field) in fields.enumerated() {
                let value: String?
                if let v = row[i] {
                    value = String(cString: v)
                } else {
                    value = nil
                }

                parsed[field] = value
            }

            results.append(parsed)
        }

        defer { mysql_free_result(resultPointer) }*/

        return []
    }

    public func parameterize(_ query: String, _ values: [String]) throws -> String {
        let parts = query
            .characters
            .split(separator: "?")
            .flatMap(String.init)

        var combined = ""

        for (i, part) in parts.enumerated() {
            let value: String

            if i < values.count {
                value = try escape(values[i])
            } else {
                value = ""
            }

            combined += part + value
        }

        return combined
    }


    public func escape(_ unescaped: String) throws -> String {
        let escapedPointer = UnsafeMutablePointer<Char>(allocatingCapacity: 1)

        defer {
            escapedPointer.deinitialize()
            escapedPointer.deallocateCapacity(1)
        }

        let length = mysql_real_escape_string(
            connection,
            escapedPointer,
            unescaped,
            strlen(unescaped)
        )
        escapedPointer
            .advanced(by: Int(length))
            .initialize(with: 0)

        guard let escaped = String(validatingUTF8: escapedPointer) else {
            throw Error.escape
        }

        return "'\(escaped)'"
    }

    private func columnCount(for statement: Statement) -> Int {
        let int32 = mysql_stmt_field_count(statement)
        return Int(int32)
    }

    public var errorMessage: String {
        guard let error = mysql_error(connection) else {
            return "Unknown"
        }
        return String(cString: error)
    }
    
    deinit {
        close()
    }

    public func close() {
        mysql_close(connection)
    }

}

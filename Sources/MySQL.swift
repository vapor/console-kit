#if os(Linux)
    import CMySQLLinux
#else
    import CMySQLMac
#endif

public class MySQL {
    public typealias FieldType = enum_field_types

    public enum Error: ErrorProtocol {
        case connection(String)
        case query(String)
        case bind(String)
        case prepare(String)
        case statement
        case fieldFetch
        case escape
    }

    public enum Value {
        case string(String)
        case int(Int)
        case uint(UInt)
        case double(Double)
        case null
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
    public func execute(_ query: String, _ values: [Value] = []) throws -> [[String: Value?]] {
        guard let statement = mysql_stmt_init(connection) else {
            throw Error.statement
        }

        guard mysql_stmt_prepare(statement, query, strlen(query)) == 0 else {
            throw Error.prepare(errorMessage)
        }

        let bindBuffer = UnsafeMutablePointer<MYSQL_BIND>(allocatingCapacity: values.count)

        for (i, value) in values.enumerated() {
            var bind = MYSQL_BIND()

            switch value {
            case .int(let int):
                bind.buffer_type = MYSQL_TYPE_LONGLONG

                let bufferLength = UInt(sizeof(Int64))

                let buffer = UnsafeMutablePointer<Int64>(allocatingCapacity: 1)
                buffer.initialize(with: Int64(int))

                bind.buffer = UnsafeMutablePointer<Void>(buffer)
                bind.buffer_length = bufferLength

                bind.length = UnsafeMutablePointer<UInt>(allocatingCapacity: 1)
                bind.length.initialize(with: bufferLength)

                bind.is_unsigned = 0
            case .string(let string):
                bind.buffer_type = MYSQL_TYPE_STRING

                let bytes = Array(string.utf8)
                let bufferLength = UInt(bytes.count)
                let buffer = UnsafeMutablePointer<Char>(allocatingCapacity: bytes.count)
                for (i, byte) in bytes.enumerated() {
                    buffer[i] = Char(bytes[i])
                }

                bind.buffer = UnsafeMutablePointer<Void>(buffer)
                bind.buffer_length = bufferLength

                bind.length = UnsafeMutablePointer<UInt>(allocatingCapacity: 1)
                bind.length.initialize(with: bufferLength)

                bind.is_unsigned = 0
            case .uint(let uint):
                bind.buffer_type = MYSQL_TYPE_LONGLONG

                let bufferLength = UInt(sizeof(UInt64))

                let buffer = UnsafeMutablePointer<UInt64>(allocatingCapacity: 1)
                buffer.initialize(with: UInt64(uint))

                bind.buffer = UnsafeMutablePointer<Void>(buffer)
                bind.buffer_length = bufferLength

                bind.length = UnsafeMutablePointer<UInt>(allocatingCapacity: 1)
                bind.length.initialize(with: bufferLength)

                bind.is_unsigned = 1
            case .null:
                bind.buffer_type = MYSQL_TYPE_NULL
            case .double(let double):
                bind.buffer_type = MYSQL_TYPE_DOUBLE

                let bufferLength = UInt(sizeof(Double))

                let buffer = UnsafeMutablePointer<Double>(allocatingCapacity: 1)
                buffer.initialize(with: double)

                bind.buffer = UnsafeMutablePointer<Void>(buffer)
                bind.buffer_length = bufferLength

                bind.length = UnsafeMutablePointer<UInt>(allocatingCapacity: 1)
                bind.length.initialize(with: bufferLength)
                
                bind.is_unsigned = 0
            }

            bindBuffer[i] = bind
        }

        defer {
            for i in 0 ..< values.count {
                let bind = bindBuffer[i]

                guard bind.buffer_type != MYSQL_TYPE_NULL else {
                    continue
                }

                let bufferLength = Int(bind.buffer_length)

                bind.buffer.deinitialize()
                bind.buffer.deallocateCapacity(bufferLength)

                bind.length.deinitialize()
                bind.length.deallocateCapacity(1)
            }
        }

        guard mysql_stmt_bind_param(statement, bindBuffer) == 0 else {
            throw Error.bind(errorMessage)
        }


        if let metadata = mysql_stmt_result_metadata(statement) {

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
                let length = Int(field.length)

                bind.buffer_length = UInt(length)

                bind.buffer = UnsafeMutablePointer<Void>(allocatingCapacity: length)
                bind.length = UnsafeMutablePointer<UInt>(allocatingCapacity: 1)
                bind.is_null = UnsafeMutablePointer<my_bool>(allocatingCapacity: 1)
                bind.error = UnsafeMutablePointer<my_bool>(allocatingCapacity: 1)

                resultBuffer[i] = bind
            }

            defer {
                for i in 0 ..< fieldsCount {
                    let field = fields[i]
                    var bind = resultBuffer[i]
                    bind.buffer.deinitialize()
                    bind.length.deinitialize()
                    bind.is_null.deinitialize()
                    bind.error.deinitialize()

                    bind.buffer.deallocateCapacity(Int(field.length))
                    bind.length.deallocateCapacity(1)
                    bind.is_null.deallocateCapacity(1)
                    bind.error.deallocateCapacity(1)
                }
            }
            
            mysql_stmt_bind_result(statement, resultBuffer)


            mysql_stmt_execute(statement)

            var results: [[String: Value?]] = []

            while mysql_stmt_fetch(statement) == Result.ok {
                var parsed: [String: Value?] = [:]

                for i in 0 ..< fieldsCount {
                    let field = fields[i]
                    let fieldName = String(cString: field.name)

                    let result = resultBuffer[i]

                    guard let buffer = result.buffer else {
                        continue
                    }

                    let value: Value?

                    func cast<T>(_ buffer: UnsafeMutablePointer<Void>, _ type: T.Type) -> UnsafeMutablePointer<T> {
                        return UnsafeMutablePointer<T>(buffer)
                    }

                    func unwrap<T>(_ buffer: UnsafeMutablePointer<Void>, _ type: T.Type) -> T {
                        return UnsafeMutablePointer<T>(buffer).pointee
                    }

                    let isNull = resultBuffer[i].is_null.pointee

                    if isNull == 1 {
                        value = nil
                    } else {
                        switch field.type {
                        case MYSQL_TYPE_STRING,
                             MYSQL_TYPE_VAR_STRING,
                             MYSQL_TYPE_BLOB,
                             MYSQL_TYPE_DECIMAL,
                             MYSQL_TYPE_NEWDECIMAL,
                             MYSQL_TYPE_ENUM,
                             MYSQL_TYPE_SET:
                            let string = String(cString: cast(buffer, Char.self))
                            value = .string(string)
                        case MYSQL_TYPE_LONG:
                            if result.is_unsigned == 1 {
                                let uint = unwrap(buffer, UInt32.self)
                                value = .uint(UInt(uint))
                            } else {
                                let int = unwrap(buffer, Int32.self)
                                value = .int(Int(int))
                            }
                        case MYSQL_TYPE_LONGLONG:
                            if result.is_unsigned == 1 {
                                let uint = unwrap(buffer, UInt64.self)
                                value = .uint(UInt(uint))
                            } else {
                                let int = unwrap(buffer, Int64.self)
                                value = .int(Int(int))
                            }
                        case MYSQL_TYPE_DOUBLE:
                            let double = unwrap(buffer, Double.self)
                            value = .double(double)
                        default:
                            value = nil
                        }
                    }

                    parsed[fieldName] = value
                }

                results.append(parsed)
                mysql_stmt_bind_result(statement, resultBuffer)
            }

            return results
        } else {
            mysql_stmt_execute(statement)
            return []
        }
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

extension MySQL.FieldType: CustomStringConvertible {
    public var description: String {
        switch self {
        case MYSQL_TYPE_TINY:
            return "TINYINT field"
        case MYSQL_TYPE_SHORT:
            return "SMALLINT field"
        case MYSQL_TYPE_LONG:
            return "INTEGER field"
        case MYSQL_TYPE_INT24:
            return "MEDIUMINT field"
        case MYSQL_TYPE_LONGLONG:
            return "BIGINT field"
        case MYSQL_TYPE_DECIMAL:
            return "DECIMAL or NUMERIC field"
        case MYSQL_TYPE_NEWDECIMAL:
            return "Precision math DECIMAL or NUMERIC"
        case MYSQL_TYPE_FLOAT:
            return "FLOAT field"
        case MYSQL_TYPE_DOUBLE:
            return "DOUBLE or REAL field"
        case MYSQL_TYPE_BIT:
            return "BIT field"
        case MYSQL_TYPE_TIMESTAMP:
            return "TIMESTAMP field"
        case MYSQL_TYPE_DATE:
            return "DATE field"
        case MYSQL_TYPE_TIME:
            return "TIME field"
        case MYSQL_TYPE_DATETIME:
            return "DATETIME field"
        case MYSQL_TYPE_YEAR:
            return "YEAR field"
        case MYSQL_TYPE_STRING:
            return "CHAR or BINARY field"
        case MYSQL_TYPE_VAR_STRING:
            return "VARCHAR or VARBINARY field"
        case MYSQL_TYPE_BLOB:
            return "BLOB or TEXT field (use max_length to determine the maximum length)"
        case MYSQL_TYPE_SET:
            return "SET field"
        case MYSQL_TYPE_ENUM:
            return "ENUM field"
        case MYSQL_TYPE_GEOMETRY:
            return "Spatial field"
        case MYSQL_TYPE_NULL:
            return "NULL-type field"
        default:
            return "unknown"
        }
    }
}
